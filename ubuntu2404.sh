#!/bin/bash
cd /opt
apt -y remove python3-nova-agent
wget https://github.com/Rackspace-DOT/nova-agent/releases/download/2.1.25/python3-nova-agent_2.1.25_all.deb
dpkg -i python3-nova-agent_2.1.25_all.deb
systemctl start python3-nova-agent
systemctl enable python3-nova-agent
apt -y remove xe-guest-utilities
wget https://github.com/xenserver/xe-guest-utilities/releases/download/v8.4.0/xe-guest-utilities_8.4.0-1_amd64.deb
dpkg -i xe-guest-utilities_8.4.0-1_amd64.deb
systemctl start xe-linux-distribution
systemctl enable xe-linux-distribution
