#!/usr/bin/env bash

main_branch_ref=$(git symbolic-ref --short refs/remotes/origin/HEAD)
main_branch="${main_branch_ref##*/}"

current_branch=$(git branch --show-current) || @milpa.fail "Could not get current branch name"

if [[ "$current_branch" != "$main_branch" ]]; then
  @milpa.log info "Checking out $main_branch"
  git checkout "$main_branch" || @milpa.fail "Could not checkout branch $main_branch"
  git pull origin "$main_branch" || @milpa.fail "Could not update main branch"

  if [[ "$MILPA_OPT_DELETE" ]]; then
    @milpa.log info "Deleting old branch $current_branch"
    git branch -D "$current_branch"
  fi
fi

function cleanup() {
  sed 's/ /-/g; s/[^a-zA-Z0-9_\/\.-]//g; s/\([_.]\)\1/\1/g' <<<"$1" 
}

ticket="$(cleanup "${MILPA_OPT_TICKET}")"
new_name="$(cleanup "${MILPA_ARG_BRANCH[*]}")"
prefix="$(cleanup "${MILPA_OPT_PREFIX}")"
new_branch="${prefix}/${ticket}/${new_name}"

@milpa.log info "creating branch $new_branch"
git checkout -b "$new_branch" || @milpa.fail "Could not create new branch"
