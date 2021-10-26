#!/usr/bin/env bash
@milpa.load_util input

set -o pipefail

# shellcheck disable=2016
search_filter='
def find_item:
if $literal != "false" then 
    .overview[$query_field] == $pattern
  else
    (.overview[$query_field] // "") | test(".*\($pattern).*"; "i")
  end;
map(
  select(find_item) |
  "\(.uuid) \(.overview.title)"
) |
if (length == 0) then
  error("No matches found for /\($pattern)/i in field \($query_field)")
else 
  sort | .[]
end'

eval "$(op signin "$OP_VAULT_NAME" --session "${!OP_SESSION_NAME}")"

function lookup () {
  op list items | 
    jq --raw-output \
      --arg literal "${MILPA_OPT_LITERAL:-false}" \
      --arg pattern "${MILPA_ARG_NEEDLE// /.*}" \
      --arg query_field "${MILPA_OPT_SEARCH}" \
      "$search_filter"
}

uuid=$(lookup) || @milpa.fail "Failed looking up secret's uuid"
matches="$(( $(wc -l <<<"$uuid") + 0 ))"


if [[ "$matches" -eq 0 ]] ; then
  @milpa.fail "Found no matches for $MILPA_ARG_NEEDLE"
elif [[ "$matches" -gt 1 ]]; then
  [[ ! -t 1 ]] && @milpa.fail "Found multiple options ($matches) for secret:
$(awk '{$1 = "-"; print $0}' <<<"$uuid")"

  name="$(@select "$(cut -d " " -f 2- <<< "$uuid")")" || @milpa.fail "Failed selecting item"
  uuid=$(sed -n "/${name//\./\.}$/p" <<<"$uuid")
fi

case "$MILPA_OPT_FIELD" in 
  "otp") exec op get totp "${uuid%% *}" ;;
  *) exec op get item "${uuid%% *}" --fields "${MILPA_OPT_FIELD}" ;;
esac
