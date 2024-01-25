# Roberto's dotfiles

so yeah, i've got a bunch of configs for my shell stuff.

## Usage

On a brand new system:

```sh
# make macos behave like regular OSes
xcode-select --install
# install milpa
curl -L https://milpa.dev/install.sh | bash -
# get the scripts
milpa itself repo install https://github.com/unRob/dotfiles.git
milpa computar bootstrap [fun|profit]
```

On an existing installation:

```sh
milpa computar provision
```
