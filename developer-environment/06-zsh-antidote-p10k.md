## ZSH Part 2: Antidote & Powerlevel10k

> Complete terminal setup: ZSH as shell, Antidote as plugin manager, Powerlevel10k as prompt.<br>
> The installation and activation of Zsh were completed in Section 1.1 (Part 1).

<img src="https://lh3.googleusercontent.com/d/1GWuo758MHQI1G9AdVX_lv9H8mXMmDrrA" width=800>

* generated files: .zsh_plugins.txt, .p10k.zsh (link)
* generated shlibs: 25-zsh-appearance.sh, 30-zsh-p10k.sh

### 2. Fonts (MesloLGS NF)

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

### 3. Antidote Plugin Manager

```shell
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
```

### 4. Plugin Selection

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

### 5. Integration into shlib

```shell
cat << 'EOF' >> ~/.shlib/shlibs/25-zsh-appearance.sh

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

### 6. p10k Config in shlib

After p10k wizard configuration, move auto-generated config into shlib:

```shell
cat << 'EOF' >> ~/.shlib/shlibs/30-zsh-p10k.sh

# ─── Custom Jupyter P10k Segment (Passive Runtime Tracker) ────────────────────
# otptional: info is folder a jupyter runtime-folder in p10k prompt
# insert in ~/.p10k.zsh to the list of segments in POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS 
# without 'prompt_', just 'my_jupyter'
function prompt_my_jupyter() {
  # Where Jupyter on Linux logs its active server processes
  local runtime_dir="${XDG_DATA_HOME:-$HOME/.local/share}/jupyter/runtime"
  # Find all server JSONs (the '(N)' prevents errors if none exist)
  local json_files=("$runtime_dir"/(jpserver|nbserver)-*.json(N))
  # If no JSON files at all -> abort immediately (costs 0 performance)
  if (( ${#json_files} == 0 )); then
    return
  fi

  local is_jupyter_dir=false
  local active_dirs=()

  # Check each JSON file: only consider servers whose PID is still alive
  local json_file
  for json_file in "${json_files[@]}"; do
    # Extract PID from filename (e.g. jpserver-17343.json -> 17343)
    local pid="${json_file##*-}"
    pid="${pid%.json}"
    # Verify the process is still running (kill -0 returns 0 if alive)
    if kill -0 "$pid" 2>/dev/null; then
      # Read root_dir from this active server
      local server_dir
      server_dir=$(grep -o '"root_dir"[[:space:]]*:[[:space:]]*"[^\}]*"' "$json_file" 2>/dev/null | head -1 | cut -d'"' -f4)
      if [[ -n "$server_dir" ]]; then
        active_dirs+=("$server_dir")
      fi
    fi
  done

  # If no active servers remain after PID check -> abort
  if (( ${#active_dirs} == 0 )); then
    return
  fi

  # Check whether the current directory ($PWD) is a (sub)folder of an active server
  local server_dir
  for server_dir in "${active_dirs[@]}"; do
    if [[ "$PWD" == "$server_dir" || "$PWD" == "$server_dir/"* ]]; then
      is_jupyter_dir=true
      break
    fi
  done

  # Hit! Active server is running and we are within its sphere of influence.
  if $is_jupyter_dir; then
    p10k segment -f 208 -i '' -t 'jupyter'
  fi
}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# and make a comfort link to the .shlib folder
ln -s ~/.p10k.zsh ~/.shlib/.p10k.zsh
```
