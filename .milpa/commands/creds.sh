#!/usr/bin/env bash

set -o pipefail

# shellcheck disable=2016
search_filter='
def find_item:
if $literal != "false" then 
    .overview.title == $pattern
  else
    .overview.title | test(".*\($pattern).*"; "i")
  end;
map(
  select(find_item) |
  "\(.uuid) \(.overview.title)"
) |
if (length == 0) then
  error("No matches found for /\($pattern)/i")
else 
  sort | .[]
end'

eval "$(op signin "$OP_VAULT_NAME" --session "${!OP_SESSION_NAME}")"

uuid="$(op list items | jq --raw-output --arg literal "${MILPA_OPT_LITERAL:-false}" --arg pattern "${MILPA_ARG_NEEDLE// /.*}" "$search_filter")" || @milpa.fail "could not search for secret uuid"

matches="$(( $(wc -l <<<"$uuid") + 0 ))"
if [[ "$matches" -eq 0 ]] ; then
  @milpa.fail "Found no matches for $MILPA_ARG_NEEDLE"
elif [[ "$matches" -gt 1 ]] && [[ ! -t 1 ]]; then
  @milpa.fail "Found multiple options ($matches) for secret:
$(awk '{$1 = "-"; print $0}' <<<"$uuid")"
fi

PS3="Select an option (1-$(( matches+1 ))): "
oldifs="$IFS"
IFS=$'\n'
names="$(cut -d " " -f 2- <<< "$uuid")"
options=($names)
IFS="$oldifs"
select opt in "${options[@]}" "Quit"; do
  if [[ "$opt" == "Quit" ]] || [[ $REPLY == "$(( ${#options[@]} + 1 ))" ]]; then
    @milpa.fail "No option selected"
  fi

  uuid=$(sed -n "${REPLY}p" <<<"$uuid")
  if [[ "$uuid" != "" ]]; then
    break
  fi
  >&2 echo "No such option, try again"
done

case "$MILPA_OPT_FIELD" in 
  "otp") exec op get totp "${uuid%% *}" ;;
  *) exec op get item "${uuid%% *}" --fields "${MILPA_OPT_FIELD}" ;;
esac
