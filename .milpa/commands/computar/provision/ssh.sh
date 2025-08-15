#!/usr/bin/env bash
@milpa.load_util user-input

if [[ "$COMPUTAR_PROFILE" != "fun" ]] && [[ "$COMPUTAR_PROFILE" != "profit" ]]; then
  @milpa.fail "Unknown computar profile"
fi

ssh_config="$HOME/.ssh/config"
hosts_config="$HOME/.ssh/config.d"

if grep "^# milpa-configured" "$ssh_config" 2>/dev/null; then
  if [[ ! "$MILPA_OPT_OVERWRITE" ]]; then
    @milpa.log complete "No SSH provisioning required"
    exit
  fi
  @milpa.log warning "Overwriting ssh config at $ssh_config"
  rm -rf "$ssh_config"
fi

mkdir -p "$HOME/.ssh"
mkdir -p "$hosts_config"

if [[ "$COMPUTAR_PROFILE" == "fun" ]]; then
  @milpa.log info "Downloading ssh config from $MILPA_OPT_BACKUP_SOURCE"
  set -o pipefail
  dst="/tmp/ssh-bootstrap"
  rm -rf "$dst"
  mkdir -p "$dst"
  curl --silent --fail --show-error -L "$MILPA_OPT_BACKUP_SOURCE" |
    openssl enc -d -aes256 |
    tar -xz -C "$dst" || @milpa.fail "Could not download ssh backup"
  set +o pipefail

  cp -rv "$dst"/* "$HOME/.ssh/"
  rm -rf "$dst"
  @milpa.log success "SSH config fetched"
else
  mkdir -p "$HOME/.ssh"
  ssh-keygen -t ed25519 -C "$COMPUTAR_USER_EMAIL" || @milpa.fail "Could not create ssh key"
  @milpa.log success "SSH key generated"

  @milpa.log info "Uploading key to github"
  gh_pat=$(@milpa.ask "Enter a token from https://github.com/settings/personal-access-tokens/new :")

  if curl --silent \
    --fail --show-error \
    -H "Authorization: Bearer $gh_pat" \
    --data "{\"title\":\"$COMPUTAR_USER_EMAIL\",\"key\":\"$(cat "${HOME}/.ssh/id_ed25519.pub")\"}" \
    https://api.github.com/user/keys > gh-result; then
    rm gh-result
    @milpa.log success "SSH key uploaded to github"
  else
    cat gh-result
    rm gh-result
    @milpa.fail "Could not upload key to github"
  fi
  @milpa.log success "Uploaded key to github"
fi

if [[ ! -f "$ssh_config" ]]; then
  @milpa.log info "Generating ssh config at $ssh_config"
  cat >>"$ssh_config" <<EOF
# milpa-configured $(date -u "+%Y-%m-%dT%H:%M:%SZ")"

Include $hosts_config/*

Host *
  PreferredAuthentications publickey,password
  GSSAPIAuthentication no
  # use -A to forward agent if needed?
  # but folks say to use proxycommand instead
  ForwardAgent no
  IdentitiesOnly yes
  AddKeysToAgent yes
  # get password from keychain on macos
  IgnoreUnknown UseKeychain
  UseKeychain yes
EOF
  @milpa.log success "SSH config generated"
fi

@milpa.log complete "SSH provisioned"
