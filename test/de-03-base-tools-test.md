# Test Base Tools, Libs & Co.

## [auto] Directories

* check if ~/bin exists
* check if ~/labor/tmp exists

## [auto] Core system essentials (nala)

* check if installed: ca-certificates curl wget gnupg gpg software-properties-common openssh-server fail2ban unattended-upgrades util-linux-extra net-tools snapd 7zip xz-utils aria2 sqlite3

## [auto] CLI tools & productivity (nala)

* check if installed: gh tmux btop htop iotop nvtop fastfetch tree hwinfo s-tui ripgrep fzf zoxide jq tealdeer shellcheck shfmt

## [auto] Build essentials & dev libraries (nala)

* check if installed: build-essential cmake make pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev libxml2-dev libxmlsec1-dev tk-dev libyaml-dev python3-openssl python3-venv python3-pip

## [auto] Multimedia & image processing (nala)

* check if installed: ffmpeg imagemagick poppler-utils portaudio19-dev libasound2-dev libsndfile1-dev libavcodec-dev libavformat-dev libswscale-dev libjpeg-dev libpng-dev libtiff-dev

## [auto] Homebrew

* check if /home/linuxbrew/.linuxbrew/bin/brew exists
* check if ~/.shlib/shlibs/22-homebrew.sh exists and contains brew shellenv
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after homebrew install)

## [auto] Brew tools

* check if installed via brew: gcc yazi lazyjournal lazydocker yq fd just direnv

## [hitl] Desktop / GUI (optional — skip on headless systems)

* if applicable: confirm flatpak is installed and flathub remote is configured
* if applicable: confirm Flatseal and Mission Center are installed via flatpak
* if applicable: confirm GRUB theme is installed and GRUB_GFXMODE is set in /etc/default/grub

## [hitl] Functional spot-check

* run `fastfetch` and confirm it displays system info
* run `btop` and confirm it shows process list
* run `yazi` and confirm it starts the file manager
