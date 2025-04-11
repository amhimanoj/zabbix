#!/bin/bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
sudo dpkg -i zabbix-release_latest_7.0+debian12_all.deb
sudo apt update
sudo apt install zabbix-agent2 zabbix-agent2-plugin-postgresql

CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"

# Ask user for the Zabbix server IP address
read -rp "Enter Zabbix server IP address: " server_ip

# Get the system's hostname
hostname=$(hostname)

# Backup the original config
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Function to set or update a key in the config file
update_config() {
    local key="$1"
    local value="$2"
    if grep -q "^$key=" "$CONFIG_FILE"; then
        sed -i "s|^$key=.*|$key=$value|" "$CONFIG_FILE"
    else
        echo "$key=$value" >> "$CONFIG_FILE"
    fi
}

# Update required parameters
update_config "Server" "$server_ip"
update_config "ListenIP" "0.0.0.0"
update_config "ListenPort" "10050"
update_config "ServerActive" "${server_ip}:10051"
update_config "Hostname" "$hostname"

echo "Zabbix agent configuration updated successfully."
echo "Backup of the original file saved as ${CONFIG_FILE}.bak"

systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
