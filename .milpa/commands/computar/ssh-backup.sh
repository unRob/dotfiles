#!/usr/bin/env bash

[[ "$COMPUTAR_PROFILE" == "fun" ]] || @milpa.fail "Refusing to create an SSH backup for a non-fun computar"

base="$HOME/.ssh"
backup="/tmp/backup.enc.tgz"

# cd into base so we can glob our way into finding our files
cd "$base" || @milpa.fail "could not cd into $base"
src=( "config.d"/* "rob@"* )


@milpa.log info "Backing up and encrypting ${src[*]}"
set -o pipefail
tar --create --gzip \
  --cd "$base" \
  --file "-" "${src[@]}" |
  openssl enc -e -aes256 -out "$backup" || @milpa.fail "Could not create archive"
set +o pipefail

trap 'rm -rf "$backup"' ERR EXIT

@milpa.log info "Uploading backup to $MILPA_ARG_TARGET/ssh-backup.tgz.enc"
# shellcheck disable=2029
scp "$backup" "$MILPA_ARG_TARGET/ssh-backup.tgz.enc" || @milpa.fail "Could not upload archive"

@milpa.log complete "SSH backup complete"

