### 1.1 🧱 Shlib System / Package Manager Policy

#### Package Manager Policy

Simple guideline on how to install what.

| Layer | Tool | Scope |
|-------|------|-------|
| OS / System | `apt` / `nala` | Core packages, system daemons, C-libraries, compilers |
| GUI Apps | `flatpak` | Desktop applications (sandboxed) |
| Modern CLI | `brew` | CLI tools + TUIs not in apt |
| Python Global | `uv tool` (or `pipx`) | Python CLI utilities (ruff, basedpyright) |
| Python Project | `uv add` / `uv sync` | ALL project dependencies |
| Python Data Science | `mamba install` + `uv pip install` | Heavy C-extensions, CUDA, ML frameworks |
| Node | `pnpm` | All JS/TS dependencies |
| Rust | `cargo` | Rust binaries and project deps |
| Go | `go install` | Go-based CLI tools |
| Java | `sdk` (SDKMAN) | JDK versions + JVM tools |
| Ruby | `gem` / `bundle` | CLI tools + project deps |


#### Shlib System

The Shlib (Shell Library) system keeps the `.zshrc` file clean and manageable by moving shell configuration into sorted, versioned files.

* **Architecture**

Three components in `.zshrc`:

1. **Lock Check** — Detects unauthorized changes to `.zshrc`
2. **Exports Loader** — Files in `~/.shlib/exports/` become env vars (filename = varname, content = value)
3. **Library Loader** — Sorted scripts in `~/.shlib/shlibs/` are sourced in order

* **Directory Structure**

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
    ├── 40-rust.sh
    ├── 45-go-config.sh
    ├── 50-java.sh
    ├── 55-ruby.sh
    └── 80-luxuspythonstack.sh -> /path/to/deen-lupysta/luxuspythonstack.sh
```

* **Numbering Convention**

Files are sourced in alphanumeric order. Numbers between known files allow future insertion:
- `05-09`: Aliases
- `10-14`: ZSH config
- `15-19`: Homebrew
- `20-24`: Appearance / plugins
- `25-29`: p10k
- `30-34`: Node
- `35-39`: Python (UV, Mamba, direnv)
- `40-44`: Rust
- `45-49`: Go
- `50-54`: Java
- `55-59`: Ruby
- `70-79`: OpenCode / agent tools
- `80-89`: Luxus Python Stack

`jupyter-launcher` and the default `jl` alias are provided by `80-luxuspythonstack.sh` (symlinked to the Luxurious Python Stack shell library).

* **Symlinked Stack Libraries**

Repository-managed shell libraries should be linked, not copied. This keeps one canonical source file and makes updates as simple as `git pull` in the repository checkout.

For Luxus Python Stack, choose the two-digit load-order number yourself and create a symlink:

```shell
ln -s /path/to/deen-lupysta/luxuspythonstack.sh \
      /path/to/.shlib/shlibs/80-luxuspythonstack.sh
```

Use a different number if your local layout requires it, for example `70-luxuspythonstack.sh` to load it earlier or `85-luxuspythonstack.sh` to load it later.

* **Lock Mechanism**

After cleaning `.zshrc` and moving configuration to shlib files, create a lock:

```shell
cp ~/.zshrc ~/.zshrc.lock
```

On each shell start, the lock snippet compares `.zshrc` against `.zshrc.lock`. If different, a diff is shown — this catches installers modifying `.zshrc` without permission.

To update the lock after intentional changes: `shliblock` or `cp ~/.zshrc ~/.zshrc.lock`.

* **Exports System**

Files in `~/.shlib/exports/` are exported as environment variables on shell start. The filename becomes the variable name, the file content (trimmed) becomes the value.

```shell
# echo "ghp_xxx" > ~/.shlib/exports/GITHUB_TOKEN
# Result: export GITHUB_TOKEN="ghp_xxx"
```

All export files should be `chmod 600` to prevent other users from reading secrets.

* **The Three Snippets**

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

* **The exact content in .zshrc**

```shell
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# >>>>>> SHLIB for zsh
# Shlib lock check (To avoid the power level warning, simply place this block before the power level code block)
SHLIB_RC_FILE="$HOME/.zshrc"; SHLIB_LOCK_FILE="$HOME/.zshrc.lock"
[ -f "$SHLIB_LOCK_FILE" ] && ! cmp -s "$SHLIB_RC_FILE" "$SHLIB_LOCK_FILE" && diff -u --color=always "$SHLIB_LOCK_FILE" "$SHLIB_RC_FILE"

# Exports all filenames in the folder as environment variables with the file content as the value.
export SHLIB_EXPORTS_DIR="$HOME/.shlib/exports"
[ -d "$SHLIB_EXPORTS_DIR" ] && for f in "$SHLIB_EXPORTS_DIR"/*(N); do [ -f "$f" ] && export "$(basename "$f")"="$(cat "$f")"; done

# Executes (sorted) all scripts in SHLIB_LIB_DIR that start with two digits.
export SHLIB_LIB_DIR="$HOME/.shlib/shlibs"
[ -d "$SHLIB_LIB_DIR" ] && for s in "$SHLIB_LIB_DIR"/[0-9][0-9]*(N); do [ -f "$s" ] && source "$s"; done
# <<<<<< SHLIB for zsh

# direnv hook (MUST BE AT THE ABSOLUTE END)
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi
```

These are the ONLY lines that should be in `.zshrc` besides the p10k instant prompt preamble and the direnv hook.
