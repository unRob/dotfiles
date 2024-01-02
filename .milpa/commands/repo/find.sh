#!/usr/bin/env bash

if [[ "$MILPA_OPT_AUTHENTICATED" ]]; then
  GITHUB_TOKEN="$(milpa creds --search website github.com --field token)"
fi

args=( -G )
if [[ "$GITHUB_TOKEN" ]]; then
  args+=( -H "Authorization: Bearer $GITHUB_TOKEN")
fi

q="${MILPA_CLONE_ORG:+org:}${MILPA_CLONE_ORG}"
if [[ "$MILPA_ARG_QUERY" =~ ^.*/ ]]; then
  q="org:${MILPA_ARG_QUERY%%/*}"
fi

if [[ "${MILPA_ARG_QUERY##*/}" ]]; then
  q="$q+${MILPA_ARG_QUERY##*/}"
fi

args+=( -d "q=$q" -d "per_page=100" )

curl --silent --fail --show-error "${args[@]}" https://api.github.com/search/repositories |
  jq -r '.items | map(.full_name) | sort[]'
