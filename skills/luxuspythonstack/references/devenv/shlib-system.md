# Shlib System

The Shlib (Shell Library) system keeps the `.zshrc` file clean and manageable by moving shell configuration into sorted, versioned files.

## Architecture

Three components in `.zshrc`:

1. **Lock Check** — Detects unauthorized changes to `.zshrc`
2. **Exports Loader** — Files in `~/.shlib/exports/` become env vars (filename = varname, content = value)
3. **Library Loader** — Sorted scripts in `~/.shlib/shlibs/` are sourced in order

## Directory Structure

```
~/.shlib/
├── exports/          # Secrets as env vars
│   ├── GITHUB_TOKEN
│   ├── PYPI_TOKEN
│   └── ...
└── shlibs/           # Sorted shell scripts
    ├── 05-aliases.sh
    ├── 10-zsh-config.sh
    ├── 15-homebrew.sh
    ├── 20-zsh-appearance.sh
    ├── 25-zsh-p10k.sh
    ├── 30-nodejs-config.sh
    ├── 35-python-config.sh
    ├── 40-jupyter-launcher.sh
    ├── 45-rust.sh
    ├── 50-go-config.sh
    ├── 55-java.sh
    ├── 60-ruby.sh
    └── 80-luxuspythonstack.sh -> /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh
```

## Numbering Convention

Files are sourced in alphanumeric order. Numbers between known files allow future insertion:
- `05-09`: Aliases
- `10-14`: ZSH config
- `15-19`: Homebrew
- `20-24`: Appearance / plugins
- `25-29`: p10k
- `30-34`: Node
- `35-39`: Python (UV, Mamba, direnv)
- `40-44`: Jupyter
- `45-49`: Rust
- `50-54`: Go
- `55-59`: Java
- `60-64`: Ruby
- `70-79`: OpenCode / agent tools
- `80-89`: Luxus Python Stack

## Symlinked Stack Libraries

Repository-managed shell libraries should be linked, not copied. This keeps one canonical source file and makes updates as simple as `git pull` in the repository checkout.

For Luxus Python Stack, choose the two-digit load-order number yourself and create a symlink:

```shell
ln -s /path/to/deen-lupysta/skills/luxuspythonstack/scripts/luxuspythonstacklib.sh \
      /path/to/.shlib/shlibs/80-luxuspythonstack.sh
```

Use a different number if your local layout requires it, for example `70-luxuspythonstack.sh` to load it earlier or `85-luxuspythonstack.sh` to load it later.

## Lock Mechanism

After cleaning `.zshrc` and moving configuration to shlib files, create a lock:

```shell
cp ~/.zshrc ~/.zshrc.lock
```

On each shell start, the lock snippet compares `.zshrc` against `.zshrc.lock`. If different, a diff is shown — this catches installers modifying `.zshrc` without permission.

To update the lock after intentional changes: `shliblock` or `cp ~/.zshrc ~/.zshrc.lock`.

## Exports System

Files in `~/.shlib/exports/` are exported as environment variables on shell start. The filename becomes the variable name, the file content (trimmed) becomes the value.

```shell
# echo "ghp_xxx" > ~/.shlib/exports/GITHUB_TOKEN
# Result: export GITHUB_TOKEN="ghp_xxx"
```

All export files should be `chmod 600` to prevent other users from reading secrets.

## The Three Snippets (exact content in .zshrc)

```shell
# >>>>>> SHLIB for zsh
SHLIB_RC_FILE="$HOME/.zshrc"; SHLIB_LOCK_FILE="$HOME/.zshrc.lock"
[ -f "$SHLIB_LOCK_FILE" ] && ! cmp -s "$SHLIB_RC_FILE" "$SHLIB_LOCK_FILE" \
    && diff -u --color=always "$SHLIB_LOCK_FILE" "$SHLIB_RC_FILE"

export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
[ -d "$SHLIB_EXPORTS_DIR" ] && for f in "$SHLIB_EXPORTS_DIR"/*(N); do \
    [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

export SHLIB_LIB_DIR="$HOME/.shlib/shlibs"
[ -d "$SHLIB_LIB_DIR" ] && for s in "$SHLIB_LIB_DIR"/[0-9][0-9]*(N); do \
    [ -f "$s" ] && source "$s"; done
# <<<<<< SHLIB for zsh
```

These are the ONLY lines that should be in `.zshrc` besides the p10k instant prompt preamble and the direnv hook.
