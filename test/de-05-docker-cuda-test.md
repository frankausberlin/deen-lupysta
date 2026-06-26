# Test Docker & CUDA Toolkit

## [auto] Docker Engine

* check if docker is installed (`which docker`)
* check if docker service is enabled and running
* check if /etc/apt/sources.list.d/docker.sources exists
* check if /etc/apt/keyrings/docker.asc exists
* check if user is in docker group (`groups $USER | grep docker`)
* check if /etc/docker/daemon.json exists and has log-driver json-file with max-size and max-file

## [hitl] Docker hello-world

* run `docker run --rm hello-world` and confirm it prints the success message
* (requires reboot or newgrp docker if user was just added to docker group)

## [auto] NVIDIA Container Toolkit (skip on machines without NVIDIA GPU)

* check if nvidia-container-toolkit is installed
* check if /etc/apt/sources.list.d/nvidia-container-toolkit.list exists
* check if `docker info` shows nvidia runtime (or `nvidia-ctk runtime --verify`)

## [hitl] GPU passthrough (skip on machines without NVIDIA GPU)

* run `docker run --rm --gpus all ubuntu nvidia-smi` and confirm GPU output is shown

## [auto] UFW-Docker patch

* check if /usr/local/bin/ufw-docker exists and is executable
* check if ufw-docker has been installed into UFW (`sudo ufw status` should show docker-related rules or DOCKER-USER chain)
