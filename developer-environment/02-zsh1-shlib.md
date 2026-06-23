## 1.1 🧱 ZSH-1 & Shlib System

### Agent Instructions

* Load the Concierge skill (`skills/concierge/SKILL.md`) and follow its rules.
* In this stage you accompany the user in installing:
  * zsh (first version, plain — appearance follows in 1.6)
  * the Shlib system
* Stage-specific notes:
  * Prerequisites from Stage 1 (Onboarding): nala, git, the `~/gits/deen-lupysta` checkout and OpenCode with the Concierge skill symlinked — must already be in place. If something is missing, stop and refer the user back to `README.md`.
  * zsh must be active before the Shlib setup. If the user just switched shells, they must log out and back in, then confirm before you continue.
  * If a Shlib system already exists (folder ~/.shlib)<br>
    1. use the [auto-test](../test/02-zsh1-shlib-test.md) to check the shlibsytem.
    2. Report problems and ask before touching anything.
    3. if all is well, give a short status report.
    4. Point out to the user that there is the possibility of carrying out further tests with their support and ask them whether they would like to do so. If so, run the tests together with the user.
  * If no Shlib system was found: 
    1. [integrate the shlib system](####Setup-Shlib-System)
    2. [write the new `.zshrc`](####The-exact-content-in-.zshrc)
    3. [test it](../test/02-zsh1-shlib-test.md)

### Zshell Part 1

```shell
# User: Install zsh and switch to zsh (nala and git are already present from Stage 1)
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

The Shlib (Shell Library) system keeps the `.zshrc` file clean and manageable by moving shell configuration into sorted files. 

#### Architecture

Three components in `.zshrc`:<br>
1. **Lock Check** — Detects unauthorized changes to `.zshrc`
2. **Exports Loader** — Files in `~/.shlib/exports/` become env vars (filename = varname, content = value)
3. **Library Loader** — Sorted scripts in `~/.shlib/shlibs/` are sourced in order

Optional use case:<br>
I recommend creating a list of system links to all important system configuration files here:<br>
e.g.: `ln -s ~/.searxng/config/settings.yml ~/.shlib/settings_searxng.yml`

#### Convention

* The numbering is freely selectable. The user must ensure consistency himself (do not use anything before it is integrated).
* In Deen Lupysta I use a mini classification system: 00 original zshrc, 10-19 deen lupysta, 20-39 diverse, 40-59 ecosystems, 60-79 ai-stack
* The file 00-original-zshrc.sh should be deleted and its contents sorted by topic and transferred to shlib files. (eg. 20-homebin.sh, 21-connectaliases.sh, 30-zsh-config.sh)

#### Setup Shlib System

```shell
# create folders
mkdir -p ~/.shlib/exports ~/.shlib/shlibs

# To be on the safe side, exclude the contents of the export folder from Github
echo  "# Ignore everything in this directory\n*\n# Except this file\n\!.gitignore" > ~/.shlib/exports/.gitignore

# The Deen Lupysta shlib: path and export tools, aliases, cw (repo was already cloned in Stage 1)
ln -s ~/gits/deen-lupysta/scripts/deenlupysta.sh ~/.shlib/shlibs/10-deenlupysta.sh

# We'll use this text here as the README.
ln -s ~/gits/deen-lupysta/developer-environment/01-shlib-policy.md ~/.shlib/README.md

# turn the current .zshrc into an shlib file (ensure that "setopt INTERACTIVE_COMMENTS" is included).
# 
mv ~/.zshrc ~/.shlib/shlibs/00-original-zshrc.sh

# Optional: I view the .shlib folder as a kind of dashboard that gives me access to the most interesting config files via file links(single point of reference)
# e.g.
ln -s ~/.zshrc ~/.shlib/.zshrc
```

#### The exact content in .zshrc

with the three snippets in the middle.

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

#### Lock Mechanism

After cleaning `.zshrc` and moving configuration to shlib files, create a lock:

```shell
cp ~/.zshrc ~/.zshrc.lock # or use the function 'shliblock' from deenlupysta.sh after 'exec zsh'
```

#### Exports System

Files in `~/.shlib/exports/` are exported as environment variables on shell start. The filename becomes the variable name, the file content (trimmed) becomes the value.

```shell
# echo "ghp_xxx" > ~/.shlib/exports/GITHUB_TOKEN
# Result: export GITHUB_TOKEN="ghp_xxx"
```

⚠️ All export files should be `chmod 600` to prevent other users from reading secrets.


#### Directory Structure
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
├── .zshrc (link --> ~/.zshrc)
├── # all system relevant configuration
└── # files as system links
```

