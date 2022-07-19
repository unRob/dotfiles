#!/usr/bin/env bash

fmt="$(@milpa.fmt warning %h)¬%ar¬$(@milpa.fmt bold %an)¬%d %s"

git log --pretty="tformat:${fmt}" "$@" |
  column -s '¬' -t |
  sed \
    -Ee "s/(Merge (branch|remote-tracking branch|pull request) .*$)/$(@milpa.fmt error '\1')/" \
    -Ee "s/(tag: ([^)]*))/$(@milpa.fmt error '\1')/" |
  less -FIRX
