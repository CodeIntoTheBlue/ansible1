#!/bin/bash

# install_ansible_semaphore.sh

# Read configuration
CONFIG=$(cat config.json)
MASTER_IP=$(echo $CONFIG | jq -r .master_server)
LINUX_SERVERS=$(echo $CONFIG | jq -r .linux_servers[])
WINDOWS_CLIENTS=$(echo $CONFIG | jq -r .windows_clients[])

# Update system
sudo apt update && sudo apt upgrade -y

# Install Ansible and other dependencies
sudo apt install -y ansible git nodejs npm mariadb-server python3-pip sshpass jq

# Install pywinrm for Windows management
sudo pip3 install pywinrm

# Generate Ansible SSH key
ssh-keygen -t ed25519 -C "ansible" -f ~/.ssh/ansible -N ""
ANSIBLE_PUBLIC_KEY=$(cat ~/.ssh/ansible.pub)

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

# Set up Semaphore (you'll need to manually input some values)
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
echo "Master server IP: $MASTER_IP"

# Deploy SSH key to Linux servers
for server in $LINUX_SERVERS; do
    sshpass -p "initial_password" ssh-copy-id -i ~/.ssh/ansible.pub ansible@$server
done

# Deploy SSH key to Windows clients (assumes WinRM is already set up)
for client in $WINDOWS_CLIENTS; do
    ansible $client -m win_authorized_key -a "user=ansible key='$ANSIBLE_PUBLIC_KEY' state=present"
done

# Generate Ansible inventory file
cat << EOF > inventory
[linux_master]
$MASTER_IP

[windows_clients]
$(echo "$WINDOWS_CLIENTS" | tr ' ' '\n')

[linux_servers]
$(echo "$LINUX_SERVERS" | tr ' ' '\n')

[all:vars]
ansible_user=ansible
EOF

echo "Inventory file has been generated."