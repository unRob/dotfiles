#!/usr/bin/env bash
repo="${HOME}/src/dotfiles"

if [[ -d "$repo" ]]; then
  # shellcheck disable=2164
  cd "$repo"
  git pull || @milpa.fail "Could not pull changes from dotfiles"
else
  repo clone unRob/dotfiles || @milpa.fail "Could not clone dotfiles"
  # uninstall the dotfile repo and install link it from the freshly cloned source
  dotfile_repo="${XDG_DATA_HOME:-$HOME/.local/share}/milpa/dotfiles"
  milpa itself repo uninstall "$dotfile_repo"
  ln -sfv "$repo/.milpa" "${XDG_DATA_HOME:-$HOME/.local/share}/milpa/dotfiles"
fi

ln -sfv "$repo" "$HOME/.dotfiles"

[[ -d "$repo/oh-my-zsh" ]] || repo clone robbyrussell/oh-my-zsh --target "$repo/oh-my-zsh" --ignore-existing || @milpa.fail "Could not clone oh-my-zsh"

for dotfile in "$repo/"*.dotfile; do
  ln -sfv "$dotfile" "$HOME/.$(basename "${dotfile%%.dotfile}")"
done
