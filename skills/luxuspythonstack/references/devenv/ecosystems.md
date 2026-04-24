# Ecosystems — Language Runtime Installation

## Node.js (fnm + pnpm)

```shell
# Install fnm (without shell modifications)
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

# Integrate into shlib (30-nodejs-config.sh):
# export FNM_PATH="$HOME/.local/share/fnm"
# [ -d "$FNM_PATH" ] && export PATH="$FNM_PATH:$PATH"
# eval "$(fnm env --use-on-cd --shell zsh)"
# export PNPM_HOME="$HOME/.local/share/pnpm"
# case ":$PATH:" in *":$PNPM_HOME:"*) ;; *) export PATH="$PNPM_HOME:$PATH" ;; esac

exec zsh
fnm install --lts && fnm use lts-latest && fnm default lts-latest
corepack enable

# Global tools
pnpm add -g @kilocode/cli pm2
```

## Python (UV + Mamba)

```shell
# pipx as fallback
sudo nala install -y python3-pip pipx

# UV
curl -LsSf https://astral.sh/uv/install.sh | sh
source "$HOME/.local/bin/env"

# Global tools via uv tool
uv tool install ruff
uv tool install bump-my-version
uv tool install basedpyright

# direnv (if not already via brew/apt)
brew install direnv

# Mamba (Miniforge)
curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -b -p "$HOME/miniforge3"
rm Miniforge3-*.sh
```

## Rust (rustup)

```shell
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# Add to shlib: [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
exec zsh

# Fast binary installs
curl -L --proto '=https' --tlsv1.2 -sSf \
  https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
cargo binstall -y cargo-watch cargo-update cargo-edit
```

## Go

```shell
sudo add-apt-repository ppa:longsleep/golang-backports -y
sudo nala update && sudo nala install -y golang-go

# Add to shlib:
# export GOPATH="$HOME/go"
# export PATH="$PATH:$GOPATH/bin"
```

## Java (SDKMAN)

```shell
curl -s "https://get.sdkman.io" | bash
# Add to shlib:
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

exec zsh
sdk install java 21.0.2-tem
sdk default java 21.0.2-tem
sdk install maven
sdk install gradle
```

> Note: SDKMAN modifies `.zshrc`. Delete the appended block — it already lives in shlib.

## Ruby (rbenv)

```shell
brew install rbenv ruby-build

# Add to shlib:
# eval "$(rbenv init - zsh)"

exec zsh
rbenv install 3.3.0
rbenv global 3.3.0
gem install bundler
```
