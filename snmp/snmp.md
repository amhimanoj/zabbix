# 📡 SNMP Client Setup Script for Debian

This guide documents a Bash script that automates the setup of an SNMP client on a Debian-based Linux system. The script installs required packages, configures SNMP, installs MIBs, and prepares the system for SNMP monitoring.

---

## 🛠️ Features

- Automatically detects and displays the system's IP address
- Installs SNMP and SNMP daemon
- Installs MIB files manually from Debian repositories
- Configures `snmpd` with custom settings
- Restarts the SNMP service
- Provides test command to verify SNMP setup

---

## 📜 Prerequisites

- Debian-based Linux system (Debian 12 recommended)
- Internet access to download packages
- Run the script with root privileges

---

## 🚀 How to Use

### 1. Save the Script

Save the following code into a file named `setup-snmp.sh`:

```bash
#!/bin/bash

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo $0"
  exit 1
fi

echo "=== Step 1: Detecting IP Address ==="
ip_address=$(hostname -I | awk '{print $1}')
echo "Detected IP address: $ip_address"

echo "=== Step 2: Updating and installing SNMP packages ==="
apt update
apt install snmp snmpd nano -y

echo "=== Step 3: Downloading MIBs ==="
wget http://ftp.debian.org/debian/pool/non-free/s/snmp-mibs-downloader/snmp-mibs-downloader_1.5_all.deb

echo "=== Step 4: Extracting and placing MIBs ==="
dpkg-deb -x snmp-mibs-downloader_1.5_all.deb temp-mibs
mkdir -p /usr/share/snmp/
mv temp-mibs/usr/share/snmp/mibs /usr/share/snmp/
rm -rf temp-mibs snmp-mibs-downloader_1.5_all.deb

echo "=== Step 5: Backing up original SNMP configuration ==="
cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.bak

echo "=== Step 6: Writing new SNMP configuration ==="
cat <<EOF > /etc/snmp/snmpd.conf
sysLocation    Sitting on the Dock of the Bay
sysContact     Me <me@example.org>
sysServices    72
master  agentx
agentaddress  0.0.0.0,161
rocommunity public 
rouser authPrivUser authpriv -V all
includeDir /etc/snmp/snmpd.conf.d
mibs:
EOF

echo "=== Step 7: Restarting SNMP service ==="
systemctl restart snmpd

echo "=== Step 8: Verifying SNMP service status ==="
systemctl status snmpd --no-pager

echo
echo "=== Test SNMP with: ==="
echo "snmpwalk -v2c -c public $ip_address"

```
### . Alternatively you can run following single command for the configuration. 

```bash

curl https://raw.githubusercontent.com/amhimanoj/zabbix/refs/heads/main/snmp/snmp-conf.sh | sudo bash
