# Test Network & Security

## [auto] SSH server

* check if ssh service is enabled (`systemctl is-enabled ssh`)
* check if ssh service is running (`systemctl is-active ssh`)

## [auto] SSH keys

* check if ~/.ssh/id_ed25519 exists
* check if ~/.ssh/id_ed25519.pub exists
* check if ~/.ssh/authorized_keys exists and has correct permissions (chmod 600)
* check if ~/.ssh has correct permissions (chmod 700)

## [auto] SSH hardening

* check if /etc/ssh/sshd_config.d/99-custom-hardening.conf exists
* check if hardening config contains: PubkeyAuthentication yes, PasswordAuthentication no, PermitRootLogin no, AllowUsers present
* check if `sudo sshd -t` passes (config is valid)
* check if ~/.shlib/99-custom-hardening.conf comfort link exists

## [auto] UFW firewall

* check if ufw is active (`sudo ufw status`)
* check if default policy is deny incoming, allow outgoing
* check if ssh is limited in ufw rules

## [auto] fail2ban

* check if fail2ban service is enabled and running
* check if /etc/fail2ban/jail.local exists and sshd jail is enabled
* check if ~/.shlib/jail.local comfort link exists

## [hitl] SSH login verification

* open a second SSH session to this machine and confirm key-based login works
* confirm password authentication is rejected (if you have a way to test)

## [hitl] Firewall verification

* confirm `sudo ufw status verbose` shows expected rules
