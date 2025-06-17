#!/bin/bash
wget https://github.com/Rackspace-DOT/nova-agent/releases/download/2.1.25/python3-nova-agent_2.1.25_all.deb
dpkg -i python3-nova-agent_2.1.25_all.deb
systemctl restart python3-nova-agent
wget https://github.com/xenserver/xe-guest-utilities/releases/download/v8.4.0/xe-guest-utilities_8.4.0-1_amd64.deb
dpkg -i xe-guest-utilities_8.4.0-1_amd64.deb
systemctl restart xe-linux-distribution
