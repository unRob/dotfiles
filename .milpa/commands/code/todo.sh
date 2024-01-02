#!/usr/bin/env bash
CURRENT_FILE=''
while IFS=":"; read -r fileName lineNo _ text; do
  if [[ $CURRENT_FILE != "$fileName" ]]; then
    [[ -n $CURRENT_FILE ]] && echo
    CURRENT_FILE=$fileName
    @milpa.fmt bold "${fileName}"
  fi

  modified=$(git blame -L "$lineNo,+1" --date=relative -c "$fileName" | awk -F$'\t' '{gsub(/ +$/, "", $3); print $3}')
  echo "L${lineNo}: ($modified) ${text# }"
done < <(cd "$(git rev-parse --show-toplevel)" && rg -i --line-number "todo(-${USER})?[:\s]")
