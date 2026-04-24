# Ubuntu Base System Setup

Full system bootstrap from blank Ubuntu to development-ready machine. Install in order.

## 1. Base Directories

```shell
mkdir -p ~/labor/tmp ~/gits ~/.shlib/exports ~/.shlib/shlibs
```

## 2. Nala (apt wrapper)

```shell
sudo apt update && sudo apt install -y nala
sudo nala update && sudo nala upgrade
```

## 3. ZSH

```shell
sudo nala install -y zsh && chsh -s $(which zsh)
# Re-login required for zsh to become the login shell
# In .shlib/shlibs/10-zsh-config.sh:
# setopt INTERACTIVE_COMMENTS
```

## 4. Core System Essentials

```shell
sudo nala install -y \
  ca-certificates curl wget gnupg gpg software-properties-common \
  openssh-server fail2ban unattended-upgrades util-linux-extra net-tools \
  snapd 7zip xz-utils aria2 sqlite3
```

## 5. CLI Tools & Productivity

```shell
sudo nala install -y \
  git gh tmux btop htop iotop nvtop fastfetch tree \
  ripgrep fzf zoxide jq tealdeer direnv shellcheck shfmt
```

## 6. Build Essentials & Dev Libraries

```shell
sudo nala install -y \
  build-essential cmake make pkg-config libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev \
  libxml2-dev libxmlsec1-dev tk-dev libyaml-dev \
  python3-openssl python3-venv python3-pip
```

## 7. Multimedia & Image Processing

```shell
sudo nala install -y \
  ffmpeg imagemagick poppler-utils \
  portaudio19-dev libasound2-dev libsndfile1-dev \
  libavcodec-dev libavformat-dev libswscale-dev \
  libjpeg-dev libpng-dev libtiff-dev
```

## 8. Ubuntu Desktop / GUI

```shell
sudo nala install -y \
  guake flatpak gnome-software-plugin-flatpak \
  gnome-shell-extension-manager libgtk-3-dev
```

### Flatpak

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub io.missioncenter.MissionCenter
```

### Snap (avoid, prefer Flatpak)

```shell
sudo systemctl enable --now snapd.socket
sudo snap refresh
```

## 9. Homebrew

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# Write to shlib: 15-homebrew.sh
brew install gcc yazi lazyjournal lazydocker yq fd
brew install just direnv
```

## 10. Package Manager Policy

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
