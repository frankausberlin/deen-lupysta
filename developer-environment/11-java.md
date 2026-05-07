### ☕ Java (SDKMAN!)

```shell
# Install SDKMAN!
curl -s "https://get.sdkman.io" | bash

# Initialize SDKMAN! for ZSH
cat << 'EOF' >> ~/.shlib/shlibs/55-java.sh

# --- SDKMAN! (Java & JVM Tools) ---
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
EOF

# Reload ZSH
exec zsh

# Install current LTS JDK and set as default
sdk install java 21.0.2-tem
sdk default java 21.0.2-tem

# Install build tools
sdk install maven
sdk install gradle
```

⚠️ After installation, SDKMAN generates code at the end of `.zshrc` with the instruction "this must be at the end". Delete it — the shell snippet is already where it belongs: `~/.shlib/shlibs/55-java.sh`. Keep your zshrc file clean.
