#!/bin/bash
wget https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb
sudo dpkg -i zabbix-release_latest_7.0+debian12_all.deb
sudo apt update
sudo apt install -y zabbix-agent2 zabbix-agent2-plugin-postgresql
systemctl restart zabbix-agent2
systemctl enable zabbix-agent2
