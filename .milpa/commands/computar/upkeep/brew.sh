#!/usr/bin/env bash
# props @lasr21
# https://x.com/lasr21/status/1728584899660222954

brew upgrade || @milpa.fail "Could not upgrade homebrew-installed software to the lastest version!"
brew autoremove || @milpa.fail "Failed during cleanup of no longer needed dependencies"
brew cleanup --prune=all || @milpa.fail "Failed during cleanup of homebrew locks and cache"
