#!/usr/bin/env bash

function @ask () {
  local prompt default result
  prompt="$1"
  if [[ "$2" ]]; then
    default="$2"
    prompt="$prompt [default: $default]"
  fi
  read -re -p "$prompt " result

  if [[ "$result" ]] || [[ "$default" ]]; then
    echo "${result:-$default}"
  else
    @milpa.warning "No value was entered, please try again."
    @ask "$prompt" "$result" "$default"
  fi
}
