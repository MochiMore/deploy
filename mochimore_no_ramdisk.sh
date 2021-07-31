#!/bin/bash

### Supported OS: Debian 10

### Update System and install dependencies
apt-get update
apt-get -y install build-essential libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev git libcap2-bin curl sudo vim bc jq git
apt autoremove -y
apt-get clean

## disable firewall port 2095
ufw allow 2095

### OPTIONAL - VIM Visual Mode off
#touch ${HOME}/.vimrc && echo "set mouse-=a" >> ${HOME}/.vimrc

### Increase open file limit for all users
echo 'mochimo-node soft nproc 16384' >> /etc/security/limits.conf 
echo 'mochimo-node hard nproc 16384' >> /etc/security/limits.conf 
echo 'mochimo-node soft nofile 16384' >> /etc/security/limits.conf  
echo 'mochimo-node hard nofile 16384' >> /etc/security/limits.conf 


## create dir for blockchain
mkdir /mnt/mochimo-bc

### Create StartUp autostart
cat <<EOF >/etc/systemd/system/mochimo.service
# Contents of /etc/systemd/system/mochimo.service
[Unit]
Description=Mochimo Mainnet Node
After=network.targe

[Service]
Type=simple
#Restart=always
#RestartSec=60
User=mochimo-node
Group=mochimo-node
WorkingDirectory=/mnt/mochimo-bc/bin/

ExecStart=/bin/bash /home/mochimo-node/start-mochimo.sh

[Install]
WantedBy=multi-user.target
EOF


chmod +x /etc/systemd/system/mochimo.service
systemctl daemon-reload
systemctl enable mochimo.service

### Create mochimo user
useradd -m -d /home/mochimo-node -s /bin/bash mochimo-node


cat <<EOF >/home/mochimo-node/start-mochimo.sh
#! /bin/bash
cd /mnt/mochimo-bc/bin
cp maddr.mat maddr.dat
./gomochi d -n -D
EOF

cd /home/mochimo-node
git clone https://github.com/mochimodev/mochimo
cd mochimo/src
./makeunx bin -DCPU
./makeunx install

chown -R mochimo-node:mochimo-node /home/mochimo-node
chmod -R 777 /home/mochimo-node/mochimo
chmod +x /home/mochimo-node/start-mochimo.sh

cp -r  /home/mochimo-node/mochimo/bin /mnt/mochimo-bc/
chown -R mochimo-node:mochimo-node /mnt/mochimo-bc
chmod -R 777 /mnt/mochimo-bc/


reboot

