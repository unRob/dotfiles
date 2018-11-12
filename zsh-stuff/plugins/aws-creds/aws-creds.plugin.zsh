function create-aws-creds () {
  local aws_env key_id secret_key profile_path

  read -re -p "Enter the account name: " aws_env
  read -re -p "Enter the key id: " key_id
  read -re -p "Enter the secret key: " secret_key

  security add-generic-password \
    -D "AWS credentials" \
    -s "aws.${AWS_ENV:-$aws_env}.aws_access_key" \
    -a "$key_id" \
    -w "$secret_key"

  profile_path="${HOME}/.config/computar/profile"
  if ! grep DEFAULT_AWS_ENV "$profile_path"; then
    echo "DEFAULT_AWS_ENV=\"${AWS_ENV}\"" >> "$profile_path"
  fi
}
