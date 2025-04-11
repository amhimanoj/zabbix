#!/bin/bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
sudo dpkg -i zabbix-release_latest_7.0+debian12_all.deb
sudo apt update
sudo apt install -y zabbix-agent2 zabbix-agent2-plugin-postgresql
CONFIG_FILE="/etc/zabbix/zabbix_agent2.conf"
BACKUP_FILE="${CONFIG_FILE}.bak"

# Backup the original config
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Ask user for server IP
read -rp "Enter the Zabbix server IP address: " server_ip

# Get system hostname
host_name=$(hostname)

# Update or insert configuration parameters
update_or_add() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}=" "$CONFIG_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$CONFIG_FILE"
    else
        echo "${key}=${value}" >> "$CONFIG_FILE"
    fi
}

# Update required fields
update_or_add "Server" "$server_ip"
update_or_add "ServerActive" "${server_ip}:10051"
update_or_add "Hostname" "$host_name"
update_or_add "ListenIP" "0.0.0.0"
update_or_add "ListenPort" "10050"

echo "Zabbix agent configuration updated successfully."
echo "Backup of the original file saved as ${CONFIG_FILE}.bak"

systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
