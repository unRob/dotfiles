# Find where asdf should be installed
ASDF_DIR="${ASDF_DIR:-$HOME/.asdf}"


# If not found, check for Homebrew package
if [[ ! -d $ASDF_DIR ]] && (( $+commands[brew] )); then
   ASDF_DIR="$(brew --prefix asdf)"
fi

# Load command
if [[ -f "$ASDF_DIR/asdf.sh" ]]; then
    # Load completions

    if [[ "$ZSH_ASDF_YES_REALLY_ZSH" == "true" ]]; then
      fpath=("$ASDF_DIR/completions" $fpath)
      autoload -Uz _asdf
      compdef _asdf asdf
    elif [[ -f "$ASDF_DIR/completions/asdf.bash" ]]; then
        . "$ASDF_DIR/completions/asdf.bash"
    fi
    
fi

