# shellcheck shell=bash
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
