#!/usr/bin/env bash
repo="${HOME}/src/dotfiles"

if [[ -d "$repo" ]]; then
  # shellcheck disable=2164
  cd "$repo"
  git pull || @milpa.fail "Could not pull changes from dotfiles"
else
  milpa repo clone unRob/dotfiles || @milpa.fail "Could not clone dotfiles"
  # uninstall the dotfile repo and install link it from the freshly cloned source
  dotfile_repo="${MILPA_COMMAND_REPO}"
  milpa itself repo uninstall "$dotfile_repo"
  ln -sfv "$repo/.milpa" "${XDG_DATA_HOME:-$HOME/.local/share}/milpa/repos/dotfiles"
fi

[[ ! -d "$HOME/.dotfiles" ]] && ln -sfv "$repo" "$HOME/.dotfiles"

[[ -d "$repo/oh-my-zsh" ]] || milpa repo clone robbyrussell/oh-my-zsh --target "$repo/oh-my-zsh" --ignore-existing || @milpa.fail "Could not clone oh-my-zsh"

for dotfile in "$repo/"*.dotfile; do
  ln -sfv "$dotfile" "$HOME/.$(basename "${dotfile%%.dotfile}")"
done
