#!/usr/bin/env bash

repo="${MILPA_ARG_REPO}"
if [[ ! "$repo" =~ "/" ]]; then
  [[ "$MILPA_CLONE_ORG" ]] || @milpa.fail "No MILPA_CLONE_ORG environment variable set, and no full repo path provided"
  repo="${MILPA_CLONE_ORG}/$repo"
fi
repo_name="${repo##*/}"

if [[ "$MILPA_OPT_TARGET" ]]; then
  base=$(dirname "$MILPA_OPT_TARGET")
  target="$MILPA_OPT_TARGET"
else
  base="$HOME/src"
  target="$base/$repo_name"
fi

[[ -d "$base" ]] || mkdir -p "$base"

if [[ -d "$target" ]]; then
  if [[ ! "$MILPA_OPT_IGNORE_EXISTING" ]]; then
    @milpa.fail "$repo_name already exists (from $(cd "$target" && git remote get-url origin))"
  fi

  @milpa.log warning "Repo $repo already exists"
  exit
fi

@milpa.log info "Cloning $(@milpa.fmt bold "$repo") into $(@milpa.fmt bold "$target")"
git clone "git@github.com:/$repo.git" "$target" || @milpa.fail "Could not clone into $target"
@milpa.log success "Cloned $repo_name into $target"

if [[ -s "$target/.gitmodules" ]]; then
  # shellcheck disable=2164
  cd "$target"
  git submodule update --init --recursive || @milpa.fail "Could not initialize git submodules"
  @milpa.log success "Git submodules initialized and updated"
fi

@milpa.log complete "$repo cloned"
