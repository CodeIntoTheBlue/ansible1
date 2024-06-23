#!/bin/bash

# Set the username and the path to the SSH key on the local machine
username=janina
ssh_key_path=~/.ssh/ansible

# Set the list of remote servers
servers=(
    192.168.178.71
    192.168.178.72
    
)

# Loop through the servers and copy the SSH key
for server in "${servers[@]}"
do
    echo "Copying SSH key to $server..."
    ssh-copy-id -i $ssh_key_path $username@$server
done
