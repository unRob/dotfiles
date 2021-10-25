#!/usr/bin/env bash
@milpa.load_util "input"

profile_path="${HOME}/.config/computar/profile"
git_profile_path="${HOME}/.config/computar/git-identity"

if [[ -f "$profile_path" ]] && [[ ! "$MILPA_OPT_FORCE" ]]; then
  @milpa.log warning "Identity profile already present, skipping"
else
  mkdir -pv "$(dirname "$profile_path")"

  name=$(@ask "How do folks call you?" "$MILPA_OPT_NAME")
  email=$(@ask "What email address should we use?" "$MILPA_OPT_EMAIL")

  @milpa.log info "Creating profile at $profile_path"
cat >"$profile_path" <<-EOF
# created by \`milpa ${MILPA_COMMAND_NAME}\` at $(date -u "+%Y-%m-%dT%H:%M:%S+0000")
# what is my email?
COMPUTAR_USER_EMAIL="$email"
# How do folks call me?
COMPUTAR_USER_NAME="$name"
# What is this computar used primarily for?
COMPUTAR_PROFILE="${MILPA_OPT_PROFILE}"
EOF
  @milpa.log success "Created profile"
fi


if [[ -f "$git_profile_path" ]] && [[ ! "$MILPA_OPT_FORCE" ]]; then
  @milpa.log warning "Git identity already present, skipping"
else
  @milpa.log info "Creating git profile at $git_profile_path"
  cat >"$git_profile_path" <<EOF
# created by \`milpa ${MILPA_COMMAND_NAME}\` at $(date -u "+%Y-%m-%dT%H:%M:%S+0000")
[user]
  name = $name
  email = $email

EOF
fi
