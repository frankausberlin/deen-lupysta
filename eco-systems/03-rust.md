## 🦀 Rust (rustup & cargo)

We use **rustup**, the official toolchain installer, to manage Rust completely cleanly and isolated in the user directory. `cargo` handles dependency management and building.

```shell
# Install Rustup & Cargo (default installation)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Make Rust environment available for ZSH via Shlib (not .zshrc!)
cat << 'EOF' > ~/.shlib/shlibs/45-rust.sh
# --- Rust / Cargo ---
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
EOF

# Reload ZSH
exec zsh

# Install Cargo-Binstall (for lightning-fast binary installations without long compiling from source)
curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install useful global Cargo tools
cargo binstall -y cargo-watch cargo-update cargo-edit
```
