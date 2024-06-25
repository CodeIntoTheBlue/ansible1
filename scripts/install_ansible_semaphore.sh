#!/bin/bash

# install_ansible_semaphore.sh
# on the master

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible and other dependencies
sudo apt install -y ansible git mariadb-server python3-pip

# Install pywinrm for Windows management
sudo pip3 install pywinrm

# Generate Ansible SSH key
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/ansible

# create a system user for semaphore
sudo adduser --system --group --home /home/semaphore semaphore

# Set up MariaDB
sudo mysql_secure_installation <<EOF

y
rootdbpasswort
rootdbpasswort
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
# search for the latest and upgrade link (manually)
wget https://github.com/semaphoreui/semaphore/releases/download/v2.10.7/semaphore_2.10.7_linux_amd64.deb
sudo apt install ./semaphore_2.10.7_linux_amd64.deb

# Set up Semaphore
sudo semaphore setup <<EOF

1

semaphore_user
passwortuser
semaphore_db








EOF


# Clone the Git repository with Ansible playbooks
git clone git@github.com:CodeIntoTheBlue/ansible1.git


# user:group change ownership
sudo chown semaphore:semaphore config.json

# directory erstellen
sudo mkdir /etc/semaphore

# change ownership
sudo chown semaphore:semaphore /etc/semaphore

# config.json verschieben
sudo mv config.json /etc/semaphore/


# Create initial config.json
cat << EOF > /etc/semaphore/config.json
{
    "master_server": "$(hostname -I | awk '{print $1}')",
    "linux_servers": [],
    "windows_clients": []
}
EOF


# creating systemd service for semaphore
# to run each time the server itself restarts

# Create Semaphore systemd service
cat << EOF | sudo tee /etc/systemd/system/semaphore.service
[Unit]
Description=Ansible Semaphore
Documentation=https://docs.ansible-semaphore.com/
Wants=network-online.target
After=network-online.target
ConditionPathExists=/usr/bin/semaphore
ConditionPathExists=/etc/semaphore/config.json

[Service]
ExecStart=/usr/bin/semaphore server --config /etc/semaphore/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=10s
User=semaphore
Group=semaphore

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable semaphore.service
sudo systemctl start semaphore.service


# to ensure Semaphore can run commands
# giving sudo rights
echo "semaphore ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/semaphore


################################
# Github konnte nicht astablished werden
# key probleme?!



# Run the Ansible playbook to complete setup
ansible-playbook ~/ansible1/playbooks/master_setup.yml

echo "Initial setup complete. Please access Semaphore to continue configuration."