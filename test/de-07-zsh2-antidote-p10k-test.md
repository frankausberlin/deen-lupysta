# Test ZSH Part 2: Antidote & Powerlevel10k

## [auto] MesloLGS NF fonts

* check if all 4 MesloLGS NF font files exist in ~/.local/share/fonts/ (Regular, Bold, Italic, Bold Italic)
* check if font cache was rebuilt (`fc-list | grep MesloLGS`)

## [auto] Antidote

* check if ~/.antidote/ exists and contains antidote.zsh
* check if ~/.shlib/.antidote comfort link exists

## [auto] Plugin selection

* check if ~/.zsh_plugins.txt exists and contains: powerlevel10k, zsh-completions, fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search, zsh-autopair
* check if ~/.shlib/.zsh_plugins.txt comfort link exists

## [auto] Shlib integration

* check if ~/.shlib/shlibs/31-zsh-appearance.sh exists and contains antidote load, compinit, zoxide init, keybindings, fzf-tab config
* check if ~/.shlib/shlibs/32-zsh-p10k.sh exists and contains p10k source line
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after zsh2 changes)

## [auto] p10k config

* check if ~/.p10k.zsh exists
* check if ~/.shlib/.p10k.zsh comfort link exists

## [hitl] Shell verification

* open a fresh shell and confirm Powerlevel10k prompt renders correctly
* confirm no errors or warnings on shell start
* confirm Tab autocompletion works (fzf-tab)
* confirm syntax highlighting is active (type a partial command and check for colors)
* confirm command history search works (type partial command and press Up arrow)

## [hitl] Guake terminal (desktop only)

* if installed: confirm Guake shell is set to zsh
* confirm Guake font is set to MesloLGS NF Regular
