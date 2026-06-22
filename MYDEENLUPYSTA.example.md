# My Deen Lupysta System - overview for agents and humans

## Hardware:
* SSD: Lexar 4TB
* CPU: AMD Ryzen 9 5950X, 16C/32T, 3.40-4.90GHz
* RAM: 96GB DDR4-3200
* GPU: RTX 3060 Ti, 8GB GDDR6


## 6.1 🟠 Stage 1: Onboarding

Summary:<br>
* opencode, nala and git are installed
* Deen Lupysta was cloned to ~/gits 
* the concierge skill was set up in opencode
* created folders: ~/gits, ~/gits/deen-lupysta, ~/deenlupysta, ~/opencode/skills/concierge (as a link)


## 6.2 🟡 Stage 2: Developer Environment

### developer-environment/01-zsh1-shlib.md

Summary:<br>
* zshell is active
* the shlib system was installed 
* shlib lock file created  
* new .zshrc content written
* The file 10-deenlupysta.sh (as a link) were added to the shlib system
* A link in the opencode skill folder with a reference to the concierge skill has been created.
* created folders: folders ~/.shlib, ~/.shlib/shlibs, ~/.shlib/exports
* A link to the .zshrc was created in ~/.shlib/.zshrc

Deviation:<br>
* The file 15-original-zshrc.sh is missing from my system


### developer-environment/02-policies.md

* Simple guideline on how to install what.


### developer-environment/03-base-tools-libs.md

All software from the instruction has been installed:<br>
* Core System Essentials
* CLI Tools & Productivity
* Build Essentials & Dev Libraries
* Multimedia & Image Processing
* GNOME desktop session Software
* Homebrew exports moved to ~/.shlib/shlibs/22-homebrew.sh
* GNOME: disable-extension-version-validation true
* The fallout grub theme is installed in /etc/default/grub 
* A link to /etc/default/grub was created in ~/.shlib/grub
* created folders: ~/bin, ~/labor, ~/labor/tmp


### developer-environment/04-net-security.md

* SSH has been enabled and keys are present in ~/.ssh
* At least one key was generated (e.g. id_ed25519)
* Enable UFW with default deny incoming, default allow outgoing, limit ssh 
* The file /etc/ssh/sshd_config.d/99-custom-hardening.conf was created with these settings:<br>
```shell
PubkeyAuthentication yes
KbdInteractiveAuthentication no
PasswordAuthentication no
PermitRootLogin no
AllowUsers $USER
PermitEmptyPasswords no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
X11Forwarding no
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
```
* The file /etc/fail2ban/jail.local was created with these settings:<br>
```shell
[sshd]
enabled = true
backend = systemd
port = ssh
filter = sshd
maxretry = 3
bantime = 3600
findtime = 3600
banaction = ufw
```
* fail2ban is running
* A link to ~/.ssh was created in ~/.shlib/.ssh
* A link to /etc/fail2ban/jail.local was created in ~/.shlib/jail.local
* A link to /etc/ssh/sshd_config.d/99-custom-hardening.conf was created in  ~/.shlib/99-custom-hardening.conf


### developer-environment/05-docker-cuda.md

* Docker is installed
* `docker run --rm hello-world` works
* Nvidia container toolkit is installed and activated with `sudo nvidia-ctk runtime configure --runtime=docker`
* `docker run --rm --gpus all ubuntu nvidia-smi` works
* UFW is installed under /usr/local/bin/ufw-docker with `sudo LC_ALL=C ufw-docker install`


### developer-environment/05-git-code-searxng.md

* git installed
* global git config: user frankausberlin, email 58914204+frankausberlin@users.noreply.github.com
* global ignore: ~/.gitignore_global
* VSCode installed via repository
* Add 'Open in Code' to context menu (nautilus) with `bash -c "$(wget -qO- https://raw.githubusercontent.com/harry-cpp/code-nautilus/master/install.sh)"`
* SearXNG was startet with:
```shell
docker run --name searxng -d --restart always -p 127.0.0.1:8080:8080 \
    -v "$HOME/.searxng/config/:/etc/searxng/" \
    -v "$HOME/.searxng/data/:/var/cache/searxng/" \
    docker.io/searxng/searxng:latest
```
* 'ultrasecretkey' replaced with real key in ~/.searxng/config/settings.yml
* A link to ~/.searxng/config/settings.yml was created in ~/.shlib/settings_searxng.yml
* Important: the JSON format for the MCP server was added in ~/.searxng/config/settings.yml under search/formats.
* created folders: ~/.searxng/, ~/.searxng/config/, ~/.searxng/data/


### developer-environment/06-zsh-antidote-p10k.md

* MesloLGS NF font is installed in ~/.local/share/fonts
* Antidote is installed ~/.antidote
* A link to ~/.antidote was created in ~/.shlib/.antidote
* The file ~/.zsh_plugins.txt was created with this list:
```shell
romkatv/powerlevel10k
zsh-users/zsh-completions
Aloxaf/fzf-tab
zsh-users/zsh-autosuggestions
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-history-substring-search
hlissner/zsh-autopair
```
* A link to ~/.zsh_plugins.txt was created in ~/.shlib/.zsh_plugins.txt
* The shlib file ~/.shlib/shlibs/31-zsh-appearance.sh was created.
* P10K was configured via wizard
* The settings inserted by P10K into the .zshrc have been moved to ~/.shlib/shlibs/32-zsh-p10k.sh.
* The prompt_my_jupyter function is located in ~/.shlib/shlibs/32-zsh-p10k.sh and has been integrated into ~/.p10k.zsh.
* The prompt_lionheart_reco function is located in ~/.shlib/shlibs/32-zsh-p10k.sh and has been integrated into ~/.p10k.zsh.
* A link to ~/.p10k.zsh was created in ~/.shlib/.p10k.zsh


## 6.3 🟢 Stage 3: Ecosystems

### 07-nodejs.md

* fnm (Fast Node Manager) is used instead of nvm (written in Rust, no shell slowdown).
* pnpm is used as the primary package manager, provided by Corepack.
* Node LTS (lts-latest) is installed and set as default.
* Corepack shims are enabled and set up for pnpm@latest.
* The shlib file ~/.shlib/shlibs/40-nodejs-config.sh was created to dynamically manage the paths for Node, fnm and pnpm.
* Important system policy: Full PATH snapshots are not stored in shlib files to prevent freezing of stale fnm_multishells paths. Path extensions are only carried out in a targeted and checked manner.
* A persistent default node path (~/.local/share/fnm/aliases/default/bin) is set up as a stable fallback for systemd services and non-interactive shells.
* Global tools were installed via pnpm: pm2.
* PM2 is successfully setup as a systemd service (pm2 startup systemd).
* All basic commands (fnm, node, npm, corepack, pnpm, npx) are verified and available in the system.


### 08-python.md      

* Python 3 Base (nala), uv (as an extremely fast Rust-based manager) and mamba (via Miniforge3) are installed.
* Central CLI tools (Ruff, bump-my-version, basedpyright, nbstripout) were provided globally via uv tool (as a performant replacement for pipx).
* A custom direnv layout for uv has been set up in ~/.config/direnv/direnvrc. The allowuv alias triggers automatic environment detection and creation in project folders.
* The shlib file ~/.shlib/shlibs/41-python-config.sh was created to orderly initialize UV, direnv (log output suppressed for p10k compatibility) and Mamba.
* Important system policy (Python protection): UV_PYTHON_PREFERENCE=only-managed is set. UV strictly uses its own Python versions to never impact the system Python.
* Important system policy (environment management): For complex environments (such as data science) the "wipe and recreate" principle applies. Instead of updating Mamba environments (which can cause conflicts when mixed with uv pip), they are completely deleted and reinstalled extremely quickly thanks to UV's speed.
* A separate act function controls the change of the Mamba environment and stores the current default persistently in ~/.startenv. (On shell startup, Mamba will be skipped if direnv finds a local .envrc in the project folder).
* Jupyter & Google Colab Compatibility: * RTC (Real-Time Collaboration) extensions have been globally disabled in ~/.jupyter/jupyter_server_config.json to permanently prevent WebSocket crashes in Google Colab.
* In the data science environment, ipywidgets==7.7.1 is strictly used for Colab runtime compatibility.
* jupyter_http_over_ws is enabled and set up as a Jupyter lab extension.


### 09-rust.md

* Rustup & Cargo are installed and working
* The file ~/.shlib/shlibs/42-rust.sh is created
* Cargo Binstall is installed
* Some tools are installed with `cargo binstall -y cargo-watch cargo-update cargo-edit`


### 10-go.md

* Go is installed via added PPA
* The file ~/.shlib/shlibs/43-go-config.sh has been created
* lf was installed with go


### 11-java.md

* SDKMAN was installed with `curl -s "https://get.sdkman.io" | bash`
* java 21.0.2-tem sdk is installed and default
* Maven and gradle are installed
* The file ~/.shlib/shlibs/44-java.sh is created


### 12-ruby.md

* Rbenv and ruby-build are installed via Homebrew
* Ruby 3.3.0 has been compiled and set global
* The file ~/.shlib/shlibs/45-ruby.sh is created
* Bundler was installed with `gem install bundler`




## 6.4 🔵 Stage 4:

01-ollama-agents.md

## 6.5 🟣 Stage 5:

02-mcphub-openwebui.md

## 6.6 🟤 Stage 6:

03-hermes-lion.md

## 6.7 ⚫ Stage 7:

04-litellm-vibekanban.md

## 6.8 ⚪ Stage 8:

05-vastai-localai.md

## 6.9 🔴 Stage 9:

