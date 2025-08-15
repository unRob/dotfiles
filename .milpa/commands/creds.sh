#!/usr/bin/env bash
@milpa.load_util user-input

set -o pipefail

# shellcheck disable=2016
search_filter='
def find_item:
  if $literal != "false" then
    .[$query_field] == $pattern
  else
    (.[$query_field] // "") | test(".*\($pattern).*"; "i")
  end;
map(
  {
    id: .id,
    title: .title,
    website: ((.urls // []) | map(select(.primary) | .href) | first)
  } |
  select(find_item) |
  "\(.id) \(.title)"
) |
if (length == 0) then
  error("No matches found for /\($pattern)/i in field \($query_field)")
else
  sort | .[]
end'

function lookup () {
  op item list --format json |
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

  name="$(@milpa.select "$(cut -d " " -f 2- <<< "$uuid")")" || @milpa.fail "Failed selecting item"
  uuid=$(sed -n "/${name//\./\.}$/p" <<<"$uuid")
fi

case "$MILPA_OPT_FIELD" in
  "otp") exec op item get --reveal --field type=otp --format json "${uuid%% *}" | jq -r .totp ;;
  .) exec op item get "${uuid%% *}" --reveal --format json | jq '.fields | map({(.label): .value}) | add' ;;
  *) exec op item get "${uuid%% *}" --reveal --field "label=${MILPA_OPT_FIELD}" ;;
esac
