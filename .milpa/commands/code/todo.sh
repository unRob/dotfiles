#!/usr/bin/env bash
CURRENT_FILE=''

function find_files () {
  git ls-files -oc --exclude-standard 2>/dev/null || find . -type f
}

function find_comments () {
  ack --files-from=<(find_files) -s -i --nogroup "todo(-${USER})?"
}


while IFS=":"; read -r fileName lineNo _ text; do
  if [[ $CURRENT_FILE != "$fileName" ]]; then
    [[ -n $CURRENT_FILE ]] && echo 
    CURRENT_FILE=$fileName
    @milpa.fmt bold "${fileName}"
  fi

  modified=$(git blame -L "$lineNo,+1" --date=relative -c "$fileName" | awk -F$'\t' '{gsub(/ +$/, "", $3); print $3}')
  echo "L${lineNo}: ($modified) ${text# }"
done < <(find_comments)
