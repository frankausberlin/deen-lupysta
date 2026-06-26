# Test ZSH-1 & Shlib System

## [auto] Zshell

* check if zsh is installed (`which zsh`)
* check if zsh is the default shell (`echo $SHELL` or read `/etc/passwd`)
* check if `setopt INTERACTIVE_COMMENTS` is set in `.zshrc` or an shlib file

## [auto] Shlib directory structure

* check if `~/.shlib/` exists
* check if `~/.shlib/exports/` exists
* check if `~/.shlib/shlibs/` exists
* check if `~/.shlib/exports/.gitignore` exists
* check if `~/.shlib/shlibs/10-deenlupysta.sh` exists and is a symlink to `~/gits/deen-lupysta/scripts/deenlupysta.sh`

## [auto] .zshrc content

* check if `~/.zshrc` exists
* check if `.zshrc` contains the shlib lock check block (`SHLIB_RC_FILE`, `SHLIB_LOCK_FILE`)
* check if `.zshrc` contains the exports loader (`SHLIB_EXPORTS_DIR`)
* check if `.zshrc` contains the library loader (`SHLIB_LIB_DIR`)
* check if `.zshrc` contains the direnv hook (at the end)

## [auto] Lock mechanism

* check if `~/.zshrc.lock` exists
* check if `.zshrc` and `.zshrc.lock` are identical (`cmp -s ~/.zshrc ~/.zshrc.lock`)

## [hitl] Shell verification

* open a fresh shell and confirm zsh is active (not bash)
* confirm no shlib lock warning appears on shell start

## [hitl] Functional check

* run `cw` and confirm it works (from deenlupysta.sh, sourced via shlib)
* run `los` or another alias from deenlupysta.sh and confirm it works
