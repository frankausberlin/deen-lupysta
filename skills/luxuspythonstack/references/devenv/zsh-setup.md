# ZSH, Antidote & Powerlevel10k

Complete terminal setup: ZSH as shell, Antidote as plugin manager, Powerlevel10k as prompt.

## 1. ZSH

```shell
# Install and switch to zsh
sudo nala install -y zsh && chsh -s $(which zsh)
```

A full re-login (logout/login) is required so that login shells pick up zsh. `exec zsh` only replaces the current interactive shell, not the login session.

Add to `~/.shlib/shlibs/10-zsh-config.sh`:

```shell
setopt INTERACTIVE_COMMENTS
```

## 2. Fonts (MesloLGS NF)

```shell
mkdir -p ~/.local/share/fonts && cd ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fc-cache -fv && cd ~
```

For Guake:
1. Set shell to `which zsh`
2. Select "Run command as a login shell"
3. Unset "Use system fixed width font"
4. Set font to MesloLGS NF Regular

## 3. Antidote Plugin Manager

```shell
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

## 4. Plugin Selection

```shell
cat << 'EOF' > ~/.zsh_plugins.txt
romkatv/powerlevel10k
zsh-users/zsh-completions
Aloxaf/fzf-tab
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
hlissner/zsh-autopair
EOF
```

## 5. Integration into shlib

```shell
cat << 'EOF' >> ~/.shlib/shlibs/20-zsh-appearance.sh

# --- Antidote & Plugins ---
source ~/.antidote/antidote.zsh
antidote load

# --- Completions & Init ---
autoload -Uz compinit && compinit

# Wake up CLI tools from the setup
eval "$(zoxide init zsh)"

# --- Keybindings & Tweaks ---
# Keybindings for history substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# fzf-tab configuration (makes Tab autocompletion nice)
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -- "$realpath"'
EOF
```

Restart terminal. Powerlevel10k will guide through the configuration wizard on first startup.

## 6. p10k Config in shlib

After p10k wizard configuration, move auto-generated config into shlib:

```shell
mv ~/.p10k.zsh ~/.shlib/shlibs/25-zsh-p10k.sh
```

## 7. Final .zshrc Structure

The `.zshrc` should contain only these sections, in this order:

```shell
# 1. p10k instant prompt (top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Shlib system (three snippets)
# >>>>>> SHLIB for zsh
SHLIB_RC_FILE="$HOME/.zshrc"; SHLIB_LOCK_FILE="$HOME/.zshrc.lock"
[ -f "$SHLIB_LOCK_FILE" ] && ! cmp -s "$SHLIB_RC_FILE" "$SHLIB_LOCK_FILE" && diff -u --color=always "$SHLIB_LOCK_FILE" "$SHLIB_RC_FILE"

export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
[ -d "$SHLIB_EXPORTS_DIR" ] && for f in "$SHLIB_EXPORTS_DIR"/*(N); do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

export SHLIB_LIB_DIR="$HOME/.shlib/shlibs"
[ -d "$SHLIB_LIB_DIR" ] && for s in "$SHLIB_LIB_DIR"/[0-9][0-9]*(N); do [ -f "$s" ] && source "$s"; done
# <<<<<< SHLIB for zsh

# 3. direnv hook (MUST BE AT THE ABSOLUTE END)
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi
```

Nothing else. All configuration lives in `~/.shlib/shlibs/`.

## 8. Shlib Lock

After cleaning `.zshrc` and creating shlib files:

```shell
cp ~/.zshrc ~/.zshrc.lock
```

The lock snippet shows a diff if any installer modifies `.zshrc` without permission.

## 9. p10k + direnv Compatibility

To prevent p10k instant-prompt warnings from direnv log output, add to `35-python-config.sh`:

```shell
export DIRENV_LOG_FORMAT=""
```

This suppresses "direnv: loading ..." and "direnv: export ..." messages that otherwise interfere with p10k's instant prompt.
