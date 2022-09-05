#!/usr/bin/env bash

quality="$(printf '%1.2f' "${MILPA_OPT_COMPRESSION}")"
lossy="$(printf '%.0f' "$(bc -l <<<"200*$quality")")"

ffmpeg \
  -hide_banner -loglevel error \
  -i "$MILPA_ARG_SOURCE" \
  -filter:v "scale='min($MILPA_OPT_SIZE,iw)':min'($MILPA_OPT_SIZE,ih)':force_original_aspect_ratio=decrease,smartblur=ls=-0.5" \
  -r 15 \
  -f gif \
  pipe:1 |
  gifsicle -i - \
    --optimize \
    --threads \
    --lossy="$lossy" \
    --output "$MILPA_OPT_OUTPUT"
