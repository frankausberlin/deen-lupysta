### 1.1 🧱 Shlib System / Package Manager Policy

#### Shlib System

The Shlib (Shell Library) system keeps the `.zshrc` file clean and manageable by moving shell configuration into sorted, versioned files.

* **Architecture**

Three components in `.zshrc`:

1. **Lock Check** — Detects unauthorized changes to `.zshrc`
2. **Exports Loader** — Files in `~/.shlib/exports/` become env vars (filename = varname, content = value)
3. **Library Loader** — Sorted scripts in `~/.shlib/shlibs/` are sourced in order

* **Convention**

The numbering is freely selectable. However, it is recommended to stick to the numbering from the developer environment and the ai stack.

* **Setup**

```shell
# create folders
mkdir -p ~/.shlib/exports ~/.shilb/shlibs

# To be on the safe side, exclude the contents of the export folder from Github
echo  "# Ignore everything in this directory\n*\n# Except this file\n\!.gitignore" > ~/.shlib/exports

# For Luxus Python Stack, replace path and number with yours
ln -s ~/gits/deen-lupysta/luxuspythonstack.sh ~/.shlib/shlibs/80-luxuspythonstack.sh

# Optional: I often open the entire .shlib folder in vsocde. For my convenience I created these links
ln -s ~/.zshrc ~/.shlib/.zshrc
ln -s ~/.p10k.zsh ~/.shlib/.p10k.zsh
# Your quickly editable favorites
```

* **Directory Structure**
```
~/.shlib/
├── exports/          # Secrets as env vars
│   ├── GITHUB_TOKEN
│   ├── PYPI_TOKEN
│   └── ...
├── shlibs/           # Sorted shell scripts
│   ├── 05-aliases.sh
│   ├── 10-zsh-config.sh
│   ├── ...
│   └── 80-luxuspythonstack.sh (link --> /path/to/deen-lupysta/luxuspythonstack.sh)
├── README.md
├── .zshrc (link --> ~/.zshrc)
└── .p10k.zsh (link --> ~/.p10k.zsh)
```

* **Lock Mechanism**

After cleaning `.zshrc` and moving configuration to shlib files, create a lock:

```shell
cp ~/.zshrc ~/.zshrc.lock
```

On each shell start, the lock snippet compares `.zshrc` against `.zshrc.lock`. If different, a diff is shown — this catches installers modifying `.zshrc` without permission.

To update the lock after intentional changes: `cp ~/.zshrc ~/.zshrc.lock`.

Optional convenience alias — add to `~/.shlib/shlibs/05-aliases.sh`:

```shell
alias shliblock='cp ~/.zshrc ~/.zshrc.lock && echo "✔ shlib lock updated"'
```

* **Exports System**

Files in `~/.shlib/exports/` are exported as environment variables on shell start. The filename becomes the variable name, the file content (trimmed) becomes the value.

```shell
# echo "ghp_xxx" > ~/.shlib/exports/GITHUB_TOKEN
# Result: export GITHUB_TOKEN="ghp_xxx"
```

All export files should be `chmod 600` to prevent other users from reading secrets.


* **The exact content in .zshrc with the three snippets in the middle.**

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

#### Package Manager Policy

Simple guideline on how to install what.

| Layer | Tool | Scope |
|-------|------|-------|
| OS / System | `apt` / `nala` | Core packages, system daemons, C-libraries, compilers |
| GUI Apps | `flatpak` | Desktop applications (sandboxed) |
| Modern CLI | `brew` | CLI tools + TUIs not in apt |
| Python Global | `uv tool` | Python CLI utilities (ruff, basedpyright); `pipx` only as fallback if `uv` is unavailable |
| Python Project | `uv add` / `uv sync` | ALL project dependencies |
| Python Data Science | `mamba install` + `uv pip install` | Heavy C-extensions, CUDA, ML frameworks |
| Node | `pnpm` | All JS/TS dependencies |
| Rust | `cargo` | Rust binaries and project deps |
| Go | `go install` | Go-based CLI tools |
| Java | `sdk` (SDKMAN) | JDK versions + JVM tools |
| Ruby | `gem` / `bundle` | CLI tools + project deps |

