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
dnf install -y curl wget vim nano
dnf install -y almalinux-release-devel
dnf repolist
dnf -y install redhat-lsb-core
