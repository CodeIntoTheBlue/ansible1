#!/bin/bash

# install_ansible_semaphore.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible
sudo apt install ansible

# Install dependencies for Semaphore
sudo apt install -y git nodejs npm mariadb-server python3-pip

# Install pywinrm for Windows management
sudo pip3 install pywinrm

# Set up MariaDB
sudo mysql_secure_installation

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

# Create Semaphore service
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

# Install and configure NGINX
sudo apt install -y nginx
sudo systemctl stop nginx

cat << EOF | sudo tee /etc/nginx/sites-available/semaphore.conf
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name semaphore.ansible.de;
    location / {
        proxy_cache_bypass $http_upgrade;
        proxy_http_version 1.1;
        proxy_pass http://localhost:3000;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
   }
}
EOF

sudo ln -s /etc/nginx/sites-available/semaphore.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "Ansible and Semaphore have been installed and configured on Ubuntu 24.04 LTS."
echo "Master server IP: 192.168.178.78"