## 1.1 🧱 Shlib System, nala, zsh-1 & Policies

* generated folders:  ~/.shlib, ~/.shlib/exports, ~/.shlib/shlibs, ~/gits
* generated shlibs: 10-deenlupysta.sh (link), 15-original-zshrc.sh
* generated files: .zshrc (shlib'ed version), .zshrc (link), README.md (link), .zshrc.lock

***I do not believe that my rules are universally correct. However, I do believe that consistent rules are better than no rules at all.***

### Nala

```shell
# use nala instead of apt
sudo apt update && sudo apt install -y nala
sudo nala update && sudo nala upgrade
```

### Zshell Part 1

```shell
# Install and switch to zsh
sudo nala install -y zsh && chsh -s $(which zsh) # Select option 2: Recommended settings
# ⚠️ A full re-login (logout/login) is required so that login shells pick up zsh.
# ⚠️ Insert after relogin and genearation of the .zshrc: 'setopt INTERACTIVE_COMMENTS' 
# This is important so that copy/paste works properly, without it the comment symbol '#' is not allowed
```

The early installation and activation of zsh serves to use the shlib system from the very beginning and throughout the entire setup process.
* Order within the `.zshrc` right from the start
* A clearer overview of what has been inserted—and by whom
* Direct access to useful tools and aliases from `deenlupysta.sh`

⚠️ The actual setup of zsh takes place in point 1.6 together with antipode and p10k.

### Shlib System

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
mkdir -p ~/.shlib/exports ~/.shlib/shlibs ~/gits

# To be on the safe side, exclude the contents of the export folder from Github
echo  "# Ignore everything in this directory\n*\n# Except this file\n\!.gitignore" > ~/.shlib/exports/.gitignore

# clone Deen Lupysta
sudo nala install git && cd ~/gits
git clone https://github.com/frankausberlin/deen-lupysta

# The Deen Lupysta shlib: path and export tools, aliases, cw
ln -s ~/gits/deen-lupysta/scripts/deenlupysta.sh ~/.shlib/shlibs/10-deenlupysta.sh

# We'll use this text here as the README.
ln -s ~/gits/deen-lupysta/developer-environment/01-shlib-policy.md ~/.shlib/README.md

# turn the current .zshrc into an shlib file (ensure that "setopt INTERACTIVE_COMMENTS" is included).
mv ~/.zshrc ~/.shlib/shlibs/15-original-zshrc.sh

# Optional: I view the .shlib folder as a kind of dashboard that gives me access to the most interesting config files via file links(single point of reference)
# e.g.
ln -s ~/.zshrc ~/.shlib/.zshrc
ln -s ~/.config/Code/User/globalStorage/kilocode.kilo-code/settings/mcp_settings.json ~/.shlib/kilo_mcps.json
```

* **The exact content in .zshrc with the three snippets in the middle.**

Insert in .zshrc (`nano ~/.zshrc`)
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

* **Lock Mechanism**

After cleaning `.zshrc` and moving configuration to shlib files, create a lock:

```shell
cp ~/.zshrc ~/.zshrc.lock # or use the alias 'shliblock' from deenlupysta.sh after 'exec zsh'
```

* **Exports System**

Files in `~/.shlib/exports/` are exported as environment variables on shell start. The filename becomes the variable name, the file content (trimmed) becomes the value.

```shell
# echo "ghp_xxx" > ~/.shlib/exports/GITHUB_TOKEN
# Result: export GITHUB_TOKEN="ghp_xxx"
```

All export files should be `chmod 600` to prevent other users from reading secrets.

* **Directory Structure**
```
~/.shlib/
├── exports/          # Secrets as env vars
│   ├── GITHUB_TOKEN
│   ├── PYPI_TOKEN
│   └── ...
├── shlibs/           # Sorted shell scripts
│   ├── 10-deenlupysta.sh
│   ├── 15-original-zshrc.sh
│   ├── ...
│   ├── <nr>-<name> (or as link: ln -s <path-to-script> ~/.shlib/shlibs/<nr>-<name>)
│   └── ...
├── README.md (link --> ~/gits/deen-lupysta/developer-environment/01-shlib-policy.md)
└── .zshrc (link --> ~/.zshrc)
```
### Policies

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

#### Working Folder Policy

* Use `cw` to switch to the current working directory
* use `cw .` to make the current directory the working directory.

⚠️ **These policies are recommendations. You are of course free to customize them. <br>
It is only recommended that you set a system once and then stick to it.**

