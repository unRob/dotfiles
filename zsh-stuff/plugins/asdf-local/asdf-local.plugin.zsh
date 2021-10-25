# Find where asdf should be installed
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"

# If not found, check for Homebrew package
if [[ ! -d $ASDF_DIR ]] && (( $+commands[brew] )); then
   ASDF_DIR="$(brew --prefix asdf)"
fi

source "$ASDF_DIR/asdf.sh"

# Load command
if [[ -f "$ASDF_DIR/asdf.sh" ]]; then
  # Load completions
  fpath=("$ASDF_DIR/completions" $fpath)
  autoload -Uz _asdf
  compdef _asdf asdf
fi

