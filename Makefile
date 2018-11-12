DOTFILES = $(wildcard *.dotfile)
HERE = $(shell pwd)
.PHONY: $(DOTFILES)

*.dotfile:
	@ln -sfv "$(HERE)/$@" "$(HOME)/$(patsubst %.dotfile,.%,$@)"

setup: $(DOTFILES)
	@echo "Installing Oh My ZSH (https://github.com/robbyrussell)"
	# given this repo doesn't need to care about oh-my-zsh's version, this is not a submodule
	# see gitignore.dotfile
	git clone git@github.com:/robbyrussell/oh-my-zsh.git $(HERE)/oh-my-zsh
	# link ourselves to a nice place
	[[ ! -d "$(HOME)/.dotfiles" ]] && ln -sfv "$(HERE)" "$(HOME)/.dotfiles"
