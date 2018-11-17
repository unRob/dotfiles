if [[ -f "${HOME}/.config/computar/profile" ]]; then
  # shellcheck disable=SC1090
  source "${HOME}/.config/computar/profile"
fi

function create_computar_profile () {
  local profile_path email
  profile_path="${HOME}/.config/computar/profile"

  mkdir -pv "$(dirname "$profile_path")"

  read -re -p "Enter your email address " email

  cat >"$profile_path" <<-EOF
  # whoami?
  DEFAULT_USER="$USER"
  # what is my email?
  DEFAULT_EMAIL="$email"
EOF
}
