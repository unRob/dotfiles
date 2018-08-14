ip (){
  # resolve a hostname to an ip address
  dig -t A "${${1%/}##*/}" +short
}

running () {
  # find a running process
  ps ax | grep "$1" | grep -v grep
}

wt () {
  # sets window title
  echo -ne "\e]1;$1\a"
}

aes-256 () {
  openssl aes-256-cbc -base64
}

decrypt-aes-256() {
  openssl aes-256-cbc -d -base64
}

encrypt-folder() {
  # backups a folder and encrypts it
  tar -cz \
    -C "$(dirname "$1")" \
    -f - \
    "$(basename "$1")" 2>/dev/null |
    aes-256 |
    cat
}

create-lifeboat() {
  local output
  output="./lifeboat-$(date -u +'%Y-%m-%dT%H-%M-%S').sh"

  cat >"$output" <<EOF
#!/usr/bin/env bash
LIFEBOAT="\${HOME}/lifeboat/\$(date -u +'%Y-%m-%dT%H-%M-%S')"
mkdir -pv "\$LIFEBOAT"
openssl base64 -d <<DATA | openssl aes-256-cbc -d | tar xfz - -C "\$LIFEBOAT" --strip-components 1
EOF
  if [[ -d "$1" ]]; then
    echo "encrypting folder $1"
    encrypt-folder "$1" >> "$output"
  elif [[ -f "$1" ]]; then
    echo "encrypting file $1"
    aes-256 < "$1" >> "$output"
  else
    echo "encrypting stdin"
    cat >> "$output"
  fi

  cat >> "$output" <<EOF
DATA
>&2 echo "Your lifeboat is decrypted at"
echo "\$LIFEBOAT"
EOF
}

function clone_repo () {
  local repo_url repo_host repo_path workdir
  repo_url="$1"
  # prepend // if repo has no protocol set so ruby doesn't explode
  [[ $repo_url != *"//"* ]] && repo_url=//${repo_url}
  repo_host=$(ruby -ruri -e "p URI.parse('$repo_url').host")
  repo_path=$(ruby -ruri -e "p URI.parse('$repo_url').path")
  workdir="${HOME}/src/${repo_host}/${repo_path}"

  mkdir -pv "$(dirname "$workdir")"
  git clone "$1" "$workdir"
}
