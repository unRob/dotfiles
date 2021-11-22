#!/usr/bin/env bash

@milpa.load_util user-input

base="$DOTFILES_PATH/brewfiles/"
brewfile="$HOME/.Brewfile"

case "$(uname -s)" in
  Darwin)
    os="macos"
    if ! xcode-select --version >/dev/null; then
      @milpa.log "Installing Command Line Tools (CLT) for Xcode, click on the thing!"
      xcode-select --install
      @milpa.confirm "Make sure CLT are installed, then"
    fi
  ;;
  Linux) os="linux" ;;
esac


if ! command -v brew >/dev/null; then
  @milpa.log info "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || @milpa.fail "could not install homebrew"
  @milpa.log info "------------------------------------------------"
  @milpa.log success "homebrew installed"
fi

echo "# Automatically generated by milpa computar provision dependencies" | cat - "$base/$os.Brewfile" "$base/$COMPUTAR_PROFILE.Brewfile" > "$brewfile" || @milpa.fail "Could not create profile Brewfile at $brewfile"

@milpa.log info "Ensuring brew dependencies are installed"
if ! brew bundle check --file "$brewfile"; then
  @milpa.log info "Installing brew dependencies"
  brew bundle install --no-lock --file "$brewfile" || @milpa.fail "Could not install dependencies"
  @milpa.log success "Brew dependencies installed"
else
  @milpa.log success "Brew dependencies up to date"
fi

@milpa.log info "Installing vscode extensions"
while read -r extension; do
  if code --list-extensions 2>/dev/null | grep -m1 "^${extension}\$" >/dev/null; then
    @milpa.log success "extension $extension already installed"
    continue
  fi

  code --install-extension "$extension" || @milpa.fail "Could not install vscode extension $extension"
    @milpa.log success "Installed extension $extension"
done < <(grep -v '^#' "${DOTFILES_PATH}/vscode.extensions")

if [[ "$os" == "macos" ]]; then
  if [[ "$(defaults read com.googlecode.iterm2 PrefsCustomFolder)" != "$DOTFILES_PATH" ]]; then
    @milpa.log "Configuring iTerm"
    defaults write com.googlecode.iterm2 PrefsCustomFolder "$DOTFILES_PATH"
    killall cfprefsd
    @milpa.log success "iterm preference folder configured"
  fi
fi

if [[ ! -d "${HOME}/.asdf" ]]; then
  @milpa.log info "Installing asdf version manager..."
  git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch v0.8.0 || @milpa.fail "Could not clone asdf-vm"
  @milpa.log success "Installed asdf-vm"

  # shellcheck disable=1091
  source "$HOME/.asdf/asdf.sh"
else
  @milpa.log success "asdf installed"
fi

@milpa.log info "installing tools from .tool-versions..."
while read -r plugin; do
  if asdf plugin list | grep -m1 "$plugin" >/dev/null; then
    @milpa.log success "asdf plugin for $plugin already installed"
    continue
  fi

  @milpa.log info "Installing $plugin asdf plugin..."
  asdf plugin-add "$plugin" || @milpa.fail "Could not install asdf plugin $plugin"
done < <(cut -d ' ' -f 1 "${HOME}/.tool-versions")

# shellcheck disable=2164
cd "$HOME";

while read -r plugin version; do
  if asdf list "$plugin" | grep -m1 "^\s*${version}\$" >/dev/null; then
    @milpa.log success "asdf: $plugin version $version is already installed"
    continue
  fi
  
  @milpa.log info "Installing $plugin version $version..."
  asdf install "$plugin" "$version" || @milpa.fail "Could not install $plugin version $version"
  @milpa.log success "$plugin version $version installed"
done <"${HOME}/.tool-versions"

@milpa.log complete "Computar has dependencies provisioned!"
