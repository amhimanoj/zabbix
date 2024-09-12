#!/bin/bash

set -e

# Install MySQL server and EPEL repository
sudo dnf install -y mysql-server epel-release

# Start and enable MySQL service
sudo systemctl start mysqld
sudo systemctl enable mysqld
# Check MySQL service status
sudo systemctl status mysqld

echo "MySQL installation completed!"

mkdir -p /root/mysql

# Create SQL files for Zabbix setup and log_bin_trust_function_creators
cat <<EOF | sudo tee /root/mysql/zabbix-setup.sql
-- Create the Zabbix database with utf8mb4 character set and collation
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

-- Create the Zabbix user with the specified password
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';

-- Grant all privileges on the Zabbix database to the user
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';

-- Enable log_bin_trust_function_creators globally
SET GLOBAL log_bin_trust_function_creators = 1;

-- Apply the privileges
FLUSH PRIVILEGES;
EOF

cat <<EOF | sudo tee /root/mysql/enable-log_bin_trust_function_creators.sql
SET GLOBAL log_bin_trust_function_creators = 0;
FLUSH PRIVILEGES;
EOF

#Until this stage its mysql preparation. 

# Add Zabbix repository and install Zabbix
echo "excludepkgs=zabbix*" | sudo tee -a /etc/yum.repos.d/oracle-epel-ol9.repo

sudo rpm -Uvh https://repo.zabbix.com/zabbix/7.0/oracle/9/x86_64/zabbix-release-7.0-5.el9.noarch.rpm

# Clean DNF cache
sudo dnf clean all

# Install Zabbix and its dependencies
sudo dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent

# Execute SQL files to configure Zabbix database
sudo mysql -u root < /root/mysql/zabbix-setup.sql
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
sudo mysql -u root < /root/mysql/enable-log_bin_trust_function_creators.sql

# Update Zabbix server configuration
echo "DBPassword=password" | sudo tee -a /etc/zabbix/zabbix_server.conf
echo "ListenIP=0.0.0.0" | sudo tee -a /etc/zabbix/zabbix_server.conf

# Update Nginx configuration
sudo sed -i 's/^# listen 8080;/listen 8080;/;s/^# server_name example.com;/server_name example.com;/' /etc/nginx/conf.d/zabbix.conf

# Restart and enable services
sudo systemctl restart zabbix-server zabbix-agent nginx php-fpm
sudo systemctl enable zabbix-server zabbix-agent nginx php-fpm

echo "Zabbix installation and configuration completed successfully!"

sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=10051/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports


#now you can access Zabbix portal on this Machines IP address. 
