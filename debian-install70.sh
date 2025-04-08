sudo apt update
sudo apt install -y locales
echo "en_US.UTF-8 UTF-8" | sudo tee /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
sudo apt install ./zabbix-release_latest_7.0+debian12_all.deb -y && sudo apt update
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2
sudo apt install -y mariadb-server
sudo systemctl enable mariadb 
sudo systemctl start mariadb
sudo mysql -uroot -p'changeme' -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin; CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; SET GLOBAL log_bin_trust_function_creators = 1;"
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
sudo mysql -uroot -p'changeme' -e "set global log_bin_trust_function_creators = 0;"
echo "DBPassword=password" | sudo tee -a /etc/zabbix/zabbix_server.conf > /dev/null
sudo sed -i -e 's/^#\s*\(listen\s\+\)/\1/' -e 's/^#\s*\(server_name\s\+\)/\1/' /etc/zabbix/nginx.conf
sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.2-fpm
sudo systemctl enable zabbix-server zabbix-agent2 nginx php8.2-fpm
