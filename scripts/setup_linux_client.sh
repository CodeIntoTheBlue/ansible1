#!/bin/bash

# setup_linux_client.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install SSH server
sudo apt install -y openssh-server

# Configure SSH for Ansible
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Create Ansible user
sudo adduser --system --group ansible
sudo usermod -aG sudo ansible

# Set up sudo rights for Ansible user
echo "ansible ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansible
sudo chmod 440 /etc/sudoers.d/ansible

echo "Linux client/server has been set up for Ansible management."
echo "Remember to copy the SSH public key from the master server."