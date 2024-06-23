#!/bin/bash

# generate_ssh_keys.sh

# Generate Ansible SSH key
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/ansible -N ""

# Generate personal SSH key
ssh-keygen -t ed25519 -C "Strong Default" -f ~/.ssh/id_ed25519

echo "SSH keys have been generated."
echo "Remember to copy the public keys to your target servers."