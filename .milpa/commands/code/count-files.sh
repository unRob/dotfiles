#!/usr/bin/env bash

set -o pipefail
find "${MILPA_ARG_DIR:-.}" -type f |
  grep -v .git |
  if [[ "$MILPA_OPT_FILTER" ]]; then
    grep "$MILPA_OPT_FILTER"
  else
    cat
  fi |
  wc -l |
  tr -d ' '
