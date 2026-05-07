### ZSH, Antidote & Powerlevel10k

<img src="https://lh3.googleusercontent.com/d/1GWuo758MHQI1G9AdVX_lv9H8mXMmDrrA" width=800>

Complete terminal setup: ZSH as shell, Antidote as plugin manager, Powerlevel10k as prompt.

#### 1. ZSH

```shell
# The installation and activation of Zsh were completed in Section 1.1.
# sudo nala install -y zsh && chsh -s $(which zsh)
```

#### 2. Fonts (MesloLGS NF)

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

#### 3. Antidote Plugin Manager

```shell
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

#### 4. Plugin Selection

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

#### 5. Integration into shlib

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

#### 6. p10k Config in shlib

After p10k wizard configuration, move auto-generated config into shlib:

```shell
cat << 'EOF' >> ~/.shlib/shlibs/25-zsh-p10k.sh

# ─── Custom Jupyter P10k Segment (Passive Runtime Tracker) ────────────────────
# otptional: info is folder a jupyter runtime-folder in p10k prompt
# insert in ~/.p10k.zsh to the list of segments in POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS 
# without 'prompt_', just 'my_jupyter'
function prompt_my_jupyter() {
  # Where Jupyter on Linux logs its active server processes
  local runtime_dir="${XDG_DATA_HOME:-$HOME/.local/share}/jupyter/runtime"
    # Find all server JSONs (the '(N)' prevents errors if none exist)
  local json_files=("$runtime_dir"/(jpserver|nbserver)-*.json(N))
    # If no server is running at all -> abort immediately (costs 0 performance)
  if (( ${#json_files} == 0 )); then
    return
  fi
  local is_jupyter_dir=false
  # Read the released paths from the running JSONs quickly using awk
  # The Zsh syntax ${(@f)$(...)} converts the rows directly into an array
  local server_dirs=("${(@f)$(cat "${json_files[@]}" 2>/dev/null | awk -F'"' '/"(root_dir|notebook_dir)"/ {print $4}' | sort -u)}")
  # Check whether the current directory ($PWD) is a (sub)folder of a running server
  local server_dir
  for server_dir in "${server_dirs[@]}"; do
    if [[ "$PWD" == "$server_dir" || "$PWD" == "$server_dir/"* ]]; then
      is_jupyter_dir=true
      break
    fi
  done
  # Hit! Server is running and we are within its sphere of influence.
  if $is_jupyter_dir; then
    p10k segment -f 208 -i '' -t 'jupyter'
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
```

#### 7. Final .zshrc Structure

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

#### 8. Shlib Lock

After cleaning `.zshrc` and creating shlib files:

```shell
cp ~/.zshrc ~/.zshrc.lock
```

The lock snippet shows a diff if any installer modifies `.zshrc` without permission.

#### 9. p10k + direnv Compatibility

To prevent p10k instant-prompt warnings from direnv log output, add to `35-python-config.sh`:

```shell
export DIRENV_LOG_FORMAT=""
```

This suppresses "direnv: loading ..." and "direnv: export ..." messages that otherwise interfere with p10k's instant prompt.
