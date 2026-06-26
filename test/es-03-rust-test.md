# Test Rust (rustup & cargo)

## [auto] Rustup & Cargo

* check if rustup is installed (`command -v rustup`)
* check if cargo is installed (`command -v cargo`)
* check if ~/.cargo/env exists
* check if ~/.shlib/shlibs/42-rust.sh exists and sources ~/.cargo/env
* check if .zshrc and .zshrc.lock are identical (shlib lock intact after rust install)

## [auto] Cargo-Binstall

* check if cargo-binstall is installed (`command -v cargo-binstall`)

## [auto] Global cargo tools

* check if cargo-watch is installed (`command -v cargo-watch` or `cargo install --list | grep cargo-watch`)
* check if cargo-update is installed
* check if cargo-edit is installed

## [hitl] Functional check

* run `rustc --version` and `cargo --version` and confirm both work
* run `cargo binstall --version` and confirm it works
