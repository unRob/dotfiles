if [[ -f "${HOME}/.config/computar/profile" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "${HOME}/.config/computar/profile"
  set +a
fi
