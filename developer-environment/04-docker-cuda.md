## Docker & CUDA Toolkit

### Agent Instructions

* Load the Concierge skill (`skills/concierge/SKILL.md`) and follow its rules.
* In this stage you accompany the user in installing:
  * Docker Engine (never docker-desktop on Linux)
  * NVIDIA Container Toolkit (GPU passthrough)
  * optionally: Portainer
* Stage-specific notes:
  * Adding the user to the `docker` group requires a reboot. The `ufw-docker` patch from stage 1.3 can only be applied *after* this reboot — coordinate the order with the user.
  * The NVIDIA Container Toolkit needs working NVIDIA drivers first (`sudo ubuntu-drivers autoinstall`). Skip the GPU part on machines without an NVIDIA GPU.
  * Verify each layer before moving on: `docker run --rm hello-world`, then `docker run --rm --gpus all ubuntu nvidia-smi`.

* manipulated files: docker.sources, daemon.json

### Docker Installation (Ubuntu)

🤮 **Never install `docker-desktop` under Linux — no CUDA support. Install Docker Engine directly.**

```shell
# Remove any existing Docker packages
sudo nala remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

# Add Docker's official GPG key
sudo nala update && sudo nala install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add repository
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Install
sudo nala update
sudo nala install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group and reboot
sudo usermod -aG docker $USER
sudo reboot # ⚠️ after reboot, you can do the ufw patch
```

Verify: `docker run --rm hello-world`

### NVIDIA Container Toolkit

Requires suitable NVIDIA drivers (`sudo ubuntu-drivers autoinstall`).

```shell
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo nala update && sudo nala install -y nvidia-container-toolkit

# Configure NVIDIA container runtime
sudo nvidia-ctk runtime configure --runtime=docker

# Log hardening (limit container log size)
jq '. + {"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"3"}}' \
   /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json.tmp >/dev/null \
 && sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

sudo systemctl restart docker
```
Verify: `docker run --rm --gpus all ubuntu nvidia-smi`

### Portainer (optional)

```shell
docker volume create portainer_data
docker run -d \
  -p 127.0.0.1:9443:9443 \
  --name portainer \
  --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest
```
