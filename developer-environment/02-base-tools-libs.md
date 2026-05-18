### 1.2 🚀 Base Tools, Libs & Co.

* generated shlibs: 20-homebrew.sh

```shell
# Home, sweet home
mkdir -p ~/bin ~/labor/tmp
```

```shell
# Core System Essentials
sudo nala install -y \
  ca-certificates curl wget gnupg gpg software-properties-common \
  openssh-server fail2ban unattended-upgrades util-linux-extra net-tools \
  snapd 7zip xz-utils aria2 sqlite3
```

```shell
# CLI Tools & Productivity
sudo nala install -y \
  git gh tmux btop htop iotop nvtop fastfetch tree hwinfo \
  ripgrep fzf zoxide jq tealdeer shellcheck shfmt
```

```shell
# Build Essentials & Dev Libraries
sudo nala install -y \
  build-essential cmake make pkg-config libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev \
  libxml2-dev libxmlsec1-dev tk-dev libyaml-dev libfuse2t64 \
  python3-openssl python3-venv python3-pip
```

```shell
# Multimedia & Image Processing
sudo nala install -y \
  ffmpeg imagemagick poppler-utils \
  portaudio19-dev libasound2-dev libsndfile1-dev \
  libavcodec-dev libavformat-dev libswscale-dev \
  libjpeg-dev libpng-dev libtiff-dev
```

```shell
# Ubuntu Desktop / GUI (OPTIONAL — skip on headless systems like a Raspberry Pi or server)
# Everything in this block assumes a GNOME desktop session.
sudo nala install -y \
  guake flatpak gnome-software-plugin-flatpak \
  gnome-shell-extension-manager libgtk-3-dev

# Flatpak (desktop only)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub io.missioncenter.MissionCenter

# Snap (avoid, prefer Flatpak)
sudo systemctl enable --now snapd.socket
sudo snap refresh
```

```shell
# Homebrew - that takes a little while
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Write to shlib: 20-homebrew.sh
echo '[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > ~/.shlib/shlibs/20-homebrew.sh

# install brew stuff
brew install gcc yazi lazyjournal lazydocker yq fd
brew install just direnv
```

```shell
# optional gnome extensions
gsettings set org.gnome.shell disable-extension-version-validation true # for new ubuntu's
# xdg-open https://extensions.gnome.org/extension/1653/tweaks-in-system-menu/
# xdg-open https://extensions.gnome.org/extension/4548/tactile/
# xdg-open https://extensions.gnome.org/extension/1319/gsconnect/

# optional embellishments
# Damask wallpaper (nasa api-key: https://api.nasa.gov/)
# xdg-open https://flathub.org/de/apps/app.drey.Damask
```

```shell
# Fallout theme for grub

# download theme installer
wget -P /tmp https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh

# review
less /tmp/fallout-grub-install.sh 

# install
bash /tmp/fallout-grub-install.sh

# change grub config
sudo nano /etc/default/grub 
# --> GRUB_GFXMODE=1920x1080x32,auto
# --> GRUB_TIMEOUT_STYLE=menu 
# --> GRUB_TIMEOUT=5

# reload grub
sudo update-grub
```
