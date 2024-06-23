#!/bin/bash

# update_config.sh

# Function to update JSON value
update_json_value() {
    local key=$1
    local value=$2
    local file=$3
    temp=$(mktemp)
    jq ".$key = $value" $file > "$temp" && mv "$temp" $file
}

# Read new values
read -p "Enter master server IP: " master_ip
read -p "Enter Linux server IPs (space-separated): " linux_servers
read -p "Enter Windows client IPs (space-separated): " windows_clients

# Update config.json
update_json_value "master_server" "\"$master_ip\"" config.json
update_json_value "linux_servers" "[$(echo $linux_servers | sed 's/ /", "/g' | sed 's/^/"/;s/$/"/')]" config.json
update_json_value "windows_clients" "[$(echo $windows_clients | sed 's/ /", "/g' | sed 's/^/"/;s/$/"/')]" config.json

echo "Configuration updated. Please re-run the setup scripts on affected machines."