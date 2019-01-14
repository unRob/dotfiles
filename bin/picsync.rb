#!/usr/bin/env ruby
# syncs my desktop pictures between computars
require 'digest'
require 'httparty'
require 'json'
require 'yaml'
require "pathname"
config_file = Pathname.new(ARGV[0] + "/.picsync.yaml")

config = YAML.load(File.read(config_file.realpath))
config['local'] = config_file.dirname.realpath
config['bucket'] = '90b4701ef2a2777d5cab071b'

if ARGV[1] == "launchd"
  command = ARGV[1]
  fullPath = config['local']
  folderName = Pathname.new(fullPath).basename
  pathToPicSync = Pathname.new(__FILE__).realpath
  dnsName = "mx.rob.picsync.#{folderName}"
  if config['source']
    launchOptions = <<~XML
      <key>WatchPaths</key>
      <array>
        <string>#{fullPath}</string>
      </array>
    XML
  else
    launchOptions = <<~XML
      <!-- start at login -->
      <key>RunAtLoad</key>
      <true />
      <!-- start every hour -->
      <key>StartInterval</key>
      <integer>3600</integer>
    XML
  end

  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{dnsName}</string>
    
        <key>Program</key>
        <string>#{pathToPicSync}</string>
    
        <key>EnvironmentVariables</key>
        <dict>
          <key>PATH</key>
          <string>#{ENV['PATH']}</string>
        </dict>

        <key>ProgramArguments</key>
        <array>
          <string>picsync.rb</string>
          <string>#{fullPath}</string>
        </array>
    
        #{launchOptions}
    
        <key>KeepAlive</key>
        <false />
    
        <key>LowPriorityIO</key>
        <true/>
    
        <key>Nice</key>
        <integer>12</integer>
    
        <key>StandardOutPath</key>
        <string>/Users/rob/Library/Logs/#{dnsName}.log</string>
    
        <key>StandardErrorPath</key>
        <string>/Users/rob/Library/Logs/#{dnsName}.log</string>
      </dict>
    </plist>
  XML

  launchd_path = "#{ENV['HOME']}/Library/LaunchAgents/#{dnsName}.plist"
  puts "Saving service at #{launchd_path}"
  File.open(launchd_path, 'w') do |f|
    f.write(xml)
  end
  exit
end

class Backblaze
  include HTTParty

  def initialize username, token, bucket
    opts = {
      basic_auth: {
        username: username,
        password: token,
      }
    }
    res = self.class.get "https://api.backblazeb2.com/b2api/v1/b2_authorize_account", opts

    if !res.ok?
      $stderr.puts res.body
      throw 'Could not login to Backblaze'
    end

    data = JSON.parse(res.body, symbolize_names: true)
    self.class.base_uri data[:apiUrl]
    @bucket = bucket
    @headers = { 'Authorization' => data[:authorizationToken] }
    @downloadEndpoint = data[:downloadUrl]
  end

  def files prefix
    body = {
      bucketId: @bucket,
      prefix: "#{prefix}/"
    }
    res = self.class.post '/b2api/v1/b2_list_file_names', body: body.to_json, headers: @headers

    JSON.parse(res.body, symbolize_names: true)[:files]
  end

  def upload name, sha, data
    params = uploadParams

    headers = params[:headers].merge({
      'Content-Type' => 'image/jpeg',
      'Content-Length' => data.size.to_s,
      'X-Bz-File-Name' => name,
      'X-Bz-Content-Sha1' => sha,
    })
    res = self.class.post params[:endpoint], body: data, headers: headers

    JSON.parse(res.body, symbolize_names: true)
  end

  def delete fileName, id
    body = {
      fileName: fileName,
      fileId: id,
    }
    res = self.class.post '/b2api/v1/b2_delete_file_version', body: body.to_json, headers: @headers

    JSON.parse(res.body, symbolize_names: true)
  end

  def download fileName, fileId, destination 
    url = "#{@downloadEndpoint}/b2api/v2/b2_download_file_by_id?fileId=#{fileId}"
    File.open("#{destination}/#{fileName}", "w") do |file|
      file.binmode
      self.class.get(url, headers: @headers, stream_body: true) do |fragment|
        file.write(fragment)
      end
    end
  end

  private

  def uploadParams
    if !@upload
      body = { bucketId: @bucket }
      res = self.class.post('/b2api/v1/b2_get_upload_url', body: body.to_json, headers: @headers)
      data = JSON.parse(res.body, symbolize_names: true)

      @upload = {
       headers: { Authorization: data[:authorizationToken] },
       endpoint: data[:uploadUrl]
      }
    end
    @upload
  end
end

b2 = Backblaze.new(config['username'], config['token'], config['bucket'])
inCloud = b2.files(config['remote']).select { |f| f[:contentType] =~ /^image/ }

cloudHas = inCloud.reduce({}) { |col, f|
    col[f[:contentSha1]] = {
      file: f[:fileName],
      id: f[:fileId],
    }
    col
  }

weHave = Dir["#{config['local']}/*.jpg"].reduce({}) do |col, f|
  sha = Digest::SHA1.file(f).hexdigest
  col[sha] = f
  col
end

if config['source']
  puts "Syncing contents of #{config['local']} to backblaze://#{config['remote']}"
  syncing = weHave.keys - cloudHas.keys
  deleting = cloudHas.keys - weHave.keys
else
  puts "Syncing from #{config['remote']} to #{config['local']}"
  syncing = cloudHas.keys - weHave.keys
  deleting = weHave.keys - cloudHas.keys
end

puts "syncing #{syncing.count}"
syncing.each do |sha|
  if config['source']
    file = weHave[sha]
    puts "uploading #{file} -> #{config['remote']}/#{sha}.jpg"
    b2.upload("#{config['remote']}/#{sha}.jpg", sha, File.read(file))
  else
    file = cloudHas[sha]
    puts "downloading #{file[:file]}"
    b2.download(file[:file], file[:id], config['local'])
  end
end

puts "deleting #{deleting.count}"
deleting.each do |sha|
  file = cloudHas[sha]
  puts "deleting #{file[:file]}"
  b2.delete(file[:file], file[:id])
end

unless deleting.empty? and syncing.empty?
  message = "#{config['remote']}: #{syncing.count}#{config['source'] ? "⬆️" : "⬇️"}"
  message += "  #{deleting.count}❌" unless deleting.empty?
  puts message
  `/usr/bin/osascript -e 'display notification "PicSync #{message}"'`
end
