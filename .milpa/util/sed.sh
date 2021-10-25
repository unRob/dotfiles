#!/usr/bin/env bash

# gnu sed and bsd sed don't behave the same with the -i flag

_sed_in_place_flag=( -i )
[[ "$(uname -s)" == "Darwin" ]] && _sed_in_place_flag+=( "" )

function @sed_in_place () {
  local pattern file; pattern="$1"; file="$2";
  sed "${_sed_in_place_flag[@]}" "$pattern" "$file"
}
