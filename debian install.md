## This document provides step-by-step instructions to install and configure Zabbix 7.2 with MariaDB on Debian 12. Each step is explained briefly.

---

## 1. Configure Locales

Reconfigure locales to ensure proper locale settings on your system. make sure to select correct Locale en_US

```bash
sudo dpkg-reconfigure locales
```


---

## 2. Update Package Repository

Always update your package lists to make sure you have the latest package information.

```bash
sudo apt update
```

---

## 3. Add the Zabbix Repository

Download the Zabbix release package for Debian 12 and install it.

```bash
wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb
sudo apt install ./zabbix-release_latest_7.2+debian12_all.deb -y
sudo apt update
```


---

## 4. Install Zabbix Components

Install the Zabbix server, frontend, Nginx configuration, SQL scripts, and agent components.

```bash
sudo apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2
```

---

## 5. Install and Configure MariaDB

Install MariaDB, enable it to start on boot, and start the service.

```bash
sudo apt install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
```

---

## 6. Configure the Zabbix Database

Create the Zabbix database and a dedicated user with the specified password, grants privileges, and adjusts the global setting for function creators  
**Note:** Replace `'changeme'` with your actual MySQL root password if needed.

```bash
sudo mysql -uroot -p'changeme' -e "CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin; CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password'; GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost'; SET GLOBAL log_bin_trust_function_creators = 1;"
```

---

## 7. Import the Zabbix Database Schema

Import the Zabbix database schema into the newly created database. Password for this command is password

```bash
zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
```

---

## 8. Restore the MariaDB Global Setting (Optional)

If you prefer, reset the `log_bin_trust_function_creators` setting back to its default behavior:

```bash
sudo mysql -uroot -p'changeme' -e "set global log_bin_trust_function_creators = 0;"
```

---

## 9. Update Zabbix Server Configuration

Append the database password setting to the Zabbix server configuration file.

```bash
echo "DBPassword=password" | sudo tee -a /etc/zabbix/zabbix_server.conf > /dev/null
```


---

## 10. Update Nginx Configuration for Zabbix

Uncomment the `listen` and `server_name` lines in the Zabbix Nginx configuration file.

```bash
sudo sed -i -e 's/^#\s*\(listen\s\+\)/\1/' -e 's/^#\s*\(server_name\s\+\)/\1/' /etc/zabbix/nginx.conf
```

---

## 11. Restart and Enable Services

Restart the Zabbix server, Zabbix agent, Nginx, and PHP-FPM services, and ensure they start automatically on boot.

```bash
sudo systemctl restart zabbix-server zabbix-agent2 nginx php8.2-fpm
sudo systemctl enable zabbix-server zabbix-agent2 nginx php8.2-fpm
```

---

## Final Notes

- **MySQL Root Password:** Make sure to replace `'changeme'` with your actual MySQL root password.
- **PHP-FPM Version:** Verify your PHP-FPM version (e.g., `php8.2-fpm`) and adjust if necessary.
- **Service Verification:** To check service status, use:
  ```bash
  sudo systemctl status <service>
  ```
  Replace `<service>` with `zabbix-server`, `zabbix-agent2`, `nginx`, or `php8.2-fpm`.

By following the above steps, you will have a fully functional Zabbix installation using MariaDB on Debian 12.

Happy Monitoring!
