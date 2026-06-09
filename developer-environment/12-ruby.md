## 💎 Ruby (rbenv & bundler)

```shell
# System dependencies for compiling Ruby:
# sudo nala install -y libyaml-dev

# Install rbenv & ruby-build via Homebrew
brew install rbenv ruby-build

# Hook rbenv into ZSH
cat << 'EOF' >> ~/.shlib/shlibs/60-ruby.sh

# --- Ruby / rbenv ---
eval "$(rbenv init - zsh)"
EOF

# Reload ZSH
exec zsh

# Compile current Ruby version and set globally (can take a few minutes!)
rbenv install 3.3.0
rbenv global 3.3.0

# Install Bundler (for dependency management)
gem install bundler
```
