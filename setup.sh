#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Step 1: Install Docker and NVIDIA container toolkit
echo "[Step 1] Installing Docker and NVIDIA container toolkit..."
curl -sSL https://get.docker.com/ | sudo sh
sudo groupadd -f docker
sudo usermod -aG docker $USER

# Add NVIDIA container repository
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update
sudo apt-get install -y nvidia-container-toolkit

# Fix Docker cgroup driver issue
sudo jq 'if has("exec-opts") then . else . + {"exec-opts": ["native.cgroupdriver=cgroupfs"]} end' /etc/docker/daemon.json \
    | sudo tee /etc/docker/daemon.json.tmp > /dev/null
sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json
sudo systemctl restart docker

# Step 2: Pull the Docker image for training
echo "[Step 2] Pulling Docker image..."
docker pull ericyuanale/llama-env:llm-v1

# Optional: Copy llama-factory directory to remote machine
# scp -r -i ~/.ssh/leximind ~/Desktop/llama-factory cc@192.5.87.227:~/llama-factory

# Step 3: Start the Docker container (bind mount your llama-factory directory)
echo "[Step 3] Starting container..."
docker run --gpus all -it --name llama-train -v ~/llama-factory:/train ericyuanale/llama-env:llm-v1 bash

# You may manually run train_inside.sh inside the container
