#!/usr/bin/env bash

framerate="$(bc <<<"1/$MILPA_OPT_DELAY")"
duration="$(printf '%1.2f' "${MILPA_OPT_DELAY}")"
quality="$(printf '%1.2f' "${MILPA_OPT_COMPRESSION}")"
lossy="$(printf '%.0f' "$(bc -l <<<"200*$quality")")"

set -o pipefail
ffmpeg \
  -hide_banner -loglevel error \
  -f concat \
  -safe 0 \
  -i <(printf -- "file '%s'\nduration $duration\n" "${MILPA_ARG_FILES[@]}") \
  -loop 0 \
  -filter:v "fps=$framerate,scale='min($MILPA_OPT_SIZE,iw)':min'($MILPA_OPT_SIZE,ih)':force_original_aspect_ratio=decrease,smartblur=ls=-0.5" \
  -f gif - |
    gifsicle -i - \
      --optimize \
      --threads \
      --lossy="$lossy" \
      --output "$MILPA_OPT_OUTPUT"
