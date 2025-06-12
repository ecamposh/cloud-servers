#!/bin/bash
nmcli networking on
dnf config-manager --set-disabled epel-cisco-openh264
dnf clean packages
dnf repolist
dnf remove -y xe-guest-utilities
dnf install -y xe-guest-utilities-latest
systemctl start xe-linux-distribution
systemctl enable xe-linux-distribution
systemctl restart nova-agent
dnf install -y wget vim nano
dnf repolist
dnf install -y redhat-lsb-core
