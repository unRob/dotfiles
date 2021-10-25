#!/usr/bin/env bash

@milpa.log info "Quihubo $(@milpa.fmt inverted "roberto")? Feliz compu nueva!"

# first we make sure an identities are available
milpa computar provision identity --profile "${MILPA_ARG_PROFILE}" || @milpa.fail "Could not create identities"

# then, we source the existing profile
set -o allexport
# shellcheck disable=1091
source "$HOME/.config/computar/profile"
set +o allexport

steps=(
  ssh
  dotfiles
  dependencies
)

for step in "${steps[@]}"; do
  milpa computar provision "$step" || @milpa.fail "Failed during \`milpa computar provision $step\`"
done

# we temporarily unlink actual zshrc to do iterm fuckery
rm "$HOME/.zshrc"

