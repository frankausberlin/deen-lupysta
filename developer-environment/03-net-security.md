## Network & Security

### Agent Instructions

* Load the Concierge skill (`skills/concierge/SKILL.md`) and follow its rules.
* In this stage you accompany the user in installing:
  * SSH (server enable + client key generation/copy)
  * SSH hardening (`99-custom-hardening.conf`)
  * UFW firewall and fail2ban
  * `ufw-docker` patch (only after Docker from stage 1.4 is installed)
* ⚠️ This is the most dangerous stage — a broken `sshd_config` can lock the user out of the machine. Treat every hardening step as critical HITL:
  * Instruct the user to keep a second SSH session open while changing `sshd_config`, so a lockout can be recovered.
  * Always validate before reloading: `sudo sshd -t && sudo systemctl reload ssh`. Never reload an unvalidated config.
  * The user executes every sudo/firewall/SSH command themselves and confirms the result before you proceed.
  * Disabling password auth (`PasswordAuthentication no`) is irreversible-by-key — make sure a working key is installed and tested first.
* Stage-specific notes:
  * The `ufw-docker` block bypasses Docker's iptables manipulation. It belongs *after* stage 1.4 (Docker). If Docker is not yet installed, defer it.

* generated files: id_ed25519.pub, id_ed25519, 99-custom-hardening.conf, jail.local

### SSH Setup

* Server Side — Enable Service

```shell
sudo systemctl enable --now ssh
```

* Client Side — Generate Key & Copy

```shell
# generate client key
ssh-keygen -t ed25519

# if it is permitted
ssh-copy-id user@host

# if it is not permitted
# 1. On the client: copy ~/.ssh/id_ed25519.pub via mail, colab, usb stick or other way
# 2. On the server:
# if not exists: mkdir -p ~/.ssh && chmod 700 ~/.ssh 
# echo "YOUR_COPYED_KEY" >> ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys

# For Termux or different ports:
ssh-copy-id -p 8022 user@host

# If "Too many authentication failures":
ssh-copy-id -o "IdentitiesOnly=yes" -i ~/.ssh/id_ed25519.pub user@host

# if you have reinstalled your system or delete the client key, remove outdated host entries
# ssh-keygen -R 'host_or_ip'
# ssh-keygen -R '[host_or_ip]:8022'
```

* SSH Hardening (`/etc/ssh/sshd_config.d/99-custom-hardening.conf`)

```ini
cat <<EOF | sudo tee /etc/ssh/sshd_config.d/99-custom-hardening.conf > /dev/null
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
EOF

# Validate config before reloading
sudo sshd -t && sudo systemctl reload ssh
```

### Firewall (UFW)

```shell
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw limit ssh       # SSH with brute-force protection
sudo ufw --force enable
```

### fail2ban 

```shell
# write /etc/fail2ban/jail.local
cat <<'EOF' | sudo tee /etc/fail2ban/jail.local > /dev/null
[sshd]
enabled = true
backend = systemd
port = ssh
filter = sshd
maxretry = 3
bantime = 3600
findtime = 3600
banaction = ufw
EOF


# restart fail2ban
sudo systemctl restart fail2ban
```

### Docker + UFW

Do this after install docker (chapter 1.4).

Docker manipulates iptables directly and bypasses UFW rules. Container ports published with `-p` may be reachable from outside even with UFW enabled. 

Install `ufw-docker` to fix the bypass:

```shell
# Download ufw-docker script
sudo wget -O /usr/local/bin/ufw-docker \
  https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker

# Install and apply (LC_ALL=C forces English output so the script recognizes the UFW "active" status)
sudo LC_ALL=C ufw-docker install
sudo systemctl restart ufw
```

### Security Best Practices

- Keep a second SSH session open when modifying sshd_config
- Use `AllowUsers` instead of `AllowGroups` for explicit access control
- Run `unattended-upgrades` for automatic security patches
- SSH keys should use ed25519 (not RSA)
- Disable password authentication on any internet-facing server
