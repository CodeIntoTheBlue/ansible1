#!/bin/bash

# install_ansible_semaphore.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible and other dependencies
sudo apt install -y ansible git nodejs npm mariadb-server python3-pip sshpass jq nginx

# Install pywinrm for Windows management
sudo pip3 install pywinrm

# Generate Ansible SSH key
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/ansible -N ""

# Set up MariaDB
sudo mysql_secure_installation <<EOF

y
passwortdb
passwortdb
y
y
y
y
EOF

# Create Semaphore database and user
sudo mariadb <<EOF
CREATE DATABASE semaphore_db;
GRANT ALL PRIVILEGES ON semaphore_db.* TO semaphore_user@localhost IDENTIFIED BY 'passwortuser';
FLUSH PRIVILEGES;
EOF

# Install Semaphore
wget https://github.com/semaphoreui/semaphore/releases/download/v2.10.7/semaphore_2.10.7_linux_amd64.deb
sudo apt install ./semaphore_2.10.7_linux_amd64.deb

# Set up Semaphore
sudo semaphore setup

# Clone the Git repository with Ansible playbooks
git clone https://your-git-repo-url.git /opt/ansible-semaphore-setup

# Create initial config.json
cat << EOF > /opt/ansible-semaphore-setup/config.json
{
    "master_server": "$(hostname -I | awk '{print $1}')",
    "linux_servers": [],
    "windows_clients": []
}
EOF

# Run the Ansible playbook to complete setup
ansible-playbook /opt/ansible-semaphore-setup/master_setup.yml

echo "Initial setup complete. Please access Semaphore to continue configuration."