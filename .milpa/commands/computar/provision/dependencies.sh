#!/usr/bin/env bash

base="$DOTFILES_PATH/brewfiles/"
brewfile="$HOME/.Brewfile"

case "$(uname -s)" in
  Darwin)
    os="macos"
    if ! xcode-select --version >/dev/null; then
      @milpa.log "Installing Command Line Tools (CLT) for Xcode, click on the thing!"
      xcode-select --install
    fi

    @ask "Once CLT are installed, enter anything to continue:"
  ;;
  Linux) os="linux" ;;
esac


if ! command -v brew >/dev/null; then
  @milpa.log info "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || @milpa.fail "could not install homebrew"
  @milpa.log info "------------------------------------------------"
  @milpa.log success "homebrew installed"
fi

cat "$base/$os.Brewfile" "$base/$COMPUTAR_PROFILE.Brewfile" > "$brewfile" || @milpa.fail "Could not create profile Brewfile at $brewfile"

@milpa.log info "Ensuring brew dependencies are installed"
if ! brew bundle check --file "$brewfile"; then
  @milpa.log info "Installing brew dependencies"
  brew bundle install --no-lock --file "$brewfile" || @milpa.fail "Could not install dependencies"
  @milpa.log success "Brew dependencies installed"
else
  @milpa.log success "Brew dependencies up to date"
fi

function _iterm_prefs_folder() {
  defaults read com.googlecode.iterm2 PrefsCustomFolder
}

if [[ "$os" == "macos" ]]; then
  if [[ "$(_iterm_prefs_folder)" != "$DOTFILES_PATH" ]]; then
    @milpa.log "Configuring iTerm"
    defaults write com.googlecode.iterm2 PrefsCustomFolder "$DOTFILES_PATH"
    killall cfprefsd
  fi
fi

if [[ -d "${HOME}/.asdf" ]]; then
   if [[ ! -d "${HOME}/.asdf" ]]; then
    @milpa.log info "Installing asdf version manager..."
    git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch v0.8.0
  fi

  log "installing tools from .tool-versions..."
  cut -d ' ' -f 1 "${HOME}/.tool-versions" | while read -r plugin; do
    asdf plugin-add "$plugin";
  done
  # shellcheck disable=2164
  cd "$HOME";
  asdf install
else
  @milpa.log success "asdf installed"
fi
