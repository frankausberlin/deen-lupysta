#!/bin/bash
# bs-03-base-tools-test.sh — Stage 2 Step 2: Base Tools, Libs & Co.
# Corresponds to:   base-system/03-base-tools-libs.md

set -euo pipefail
PASS=0; FAIL=0; SKIP=0

ok()   { echo "  PASS: $1"; PASS=$((PASS+1)); }
no()   { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
skip() { echo "  SKIP: $1"; SKIP=$((SKIP+1)); }

echo "=== bs-03: Base Tools, Libs & Co. ==="

# --- [auto] Directories ---
for d in ~/bin ~/labor ~/labor/tmp; do
  if [ -d "$d" ]; then
    ok "$d exists"
  else
    no "$d missing"
  fi
done

# --- [auto] Core system essentials ---
CORE="ca-certificates curl wget gnupg gpg software-properties-common openssh-server fail2ban unattended-upgrades util-linux-extra net-tools snapd 7zip xz-utils aria2 sqlite3"
MISSING=""
for pkg in $CORE; do
  if ! dpkg -l "$pkg" &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all core system essentials installed"
else
  no "missing core packages:$MISSING"
fi

# --- [auto] CLI tools & productivity ---
CLI="gh tmux btop htop iotop nvtop fastfetch tree hwinfo s-tui ripgrep fzf zoxide jq tealdeer shellcheck shfmt"
MISSING=""
for pkg in $CLI; do
  if ! dpkg -l "$pkg" &>/dev/null && ! command -v "$pkg" &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all CLI tools installed"
else
  no "missing CLI tools:$MISSING"
fi

# --- [auto] Build essentials & dev libraries ---
BUILD="build-essential cmake make pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses-dev libffi-dev liblzma-dev libxml2-dev libxmlsec1-dev tk-dev libyaml-dev python3-openssl python3-venv python3-pip"
MISSING=""
for pkg in $BUILD; do
  if ! dpkg -l "$pkg" &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all build essentials installed"
else
  no "missing build packages:$MISSING"
fi

# --- [auto] Multimedia & image processing ---
MULTI="ffmpeg imagemagick poppler-utils portaudio19-dev libasound2-dev libsndfile1-dev libavcodec-dev libavformat-dev libswscale-dev libjpeg-dev libpng-dev libtiff-dev"
MISSING=""
for pkg in $MULTI; do
  if ! dpkg -l "$pkg" &>/dev/null; then
    MISSING="$MISSING $pkg"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all multimedia packages installed"
else
  no "missing multimedia packages:$MISSING"
fi

# --- [auto] Homebrew ---
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
  ok "homebrew installed"
else
  no "homebrew not installed"
fi

if [ -f ~/.shlib/shlibs/22-homebrew.sh ] && grep -q "brew shellenv" ~/.shlib/shlibs/22-homebrew.sh 2>/dev/null; then
  ok "22-homebrew.sh exists and contains brew shellenv"
else
  no "22-homebrew.sh missing or invalid"
fi

if [ -f ~/.zshrc ] && [ -f ~/.zshrc.lock ]; then
  if cmp -s ~/.zshrc ~/.zshrc.lock; then
    ok "shlib lock intact after homebrew install"
  else
    no "shlib lock violated (homebrew may have tampered)"
  fi
fi

# --- [auto] Brew tools ---
BREW="gcc yazi lazyjournal lazydocker yq fd just direnv"
MISSING=""
for tool in $BREW; do
  if ! command -v "$tool" &>/dev/null; then
    MISSING="$MISSING $tool"
  fi
done
if [ -z "$MISSING" ]; then
  ok "all brew tools installed"
else
  no "missing brew tools:$MISSING"
fi

# --- [hitl] Desktop / GUI (optional — skip on headless systems) ---
# If applicable:
#   - confirm flatpak is installed and flathub remote is configured
#   - confirm Flatseal and Mission Center are installed via flatpak
#   - confirm GRUB theme is installed and GRUB_GFXMODE is set in /etc/default/grub
# Uncomment to run:
# flatpak list | grep -i flatseal
# flatpak list | grep -i mission-center
# grep GRUB_GFXMODE /etc/default/grub

# --- [hitl] Functional spot-check ---
# Run `fastfetch` and confirm it displays system info
# Run `btop` and confirm it shows process list
# Run `yazi` and confirm it starts the file manager
# Uncomment to run:
# fastfetch
# btop
# yazi

echo ""
echo "Results: $PASS pass, $FAIL fail, $SKIP skip"
[ "$FAIL" -eq 0 ]
