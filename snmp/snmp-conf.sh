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
