# shellcheck shell=bash

tab_title () {
  # sets window title
  echo -ne "\e]1;$1\a"
}

tab_color () {
  # sets tab color
  local r g b color;
  color="$1"
  if [[ "${#color}" == 3 ]]; then
    r="${color:0:1}${color:0:1}"
    g="${color:1:1}${color:1:1}"
    b="${color:2:1}${color:2:1}"
  elif [[ "${#color}" == 6 ]]; then
    r="${color:0:2}"
    g="${color:2:2}"
    b="${color:4:2}"
  fi
  iterm2_tab_color $(( 16#$r )) $(( 16#$g )) $(( 16#$b ))
}
