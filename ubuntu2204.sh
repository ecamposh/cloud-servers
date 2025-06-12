#!/bin/bash
# wget http://archive.ubuntu.com/ubuntu/pool/main/x/xe-guest-utilities/xe-guest-utilities_7.10.0-0ubuntu1_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/universe/x/xe-guest-utilities/xe-guest-utilities_7.20.2-0ubuntu1~22.04.2_amd64.deb
dpkg -i xe-guest-utilities_7.20.2-0ubuntu1~22.04.2_amd64.deb
systemctl start xe-daemon
systemctl enable xe-daemon
apt update
apt -y install xenstore-utils
# wget https://mirror.rackspace.com/ospc/debian_new/pool/main/n/nova-agent/python3-nova-agent_2.1.23_all.deb
wget https://github.com/Rackspace-DOT/nova-agent/releases/download/2.1.25/python3-nova-agent_2.1.25_all.deb
dpkg -i python3-nova-agent_2.1.25_all.deb
systemctl start python3-nova-agent
systemctl enable python3-nova-agent
