#!/bin/bash
# Works on Rocky and Alma Linux 8

# Exit on error
set -e

# Uncomment the following line under Rocky Linux
# dnf config-manager --set-disabled epel-cisco-openh264

echo "Change Locale"
# locale -a
echo "export LANGUAGE=en_US.utf8" >> /etc/environment
echo "export LANG=en_US.utf8" >> /etc/environment
echo "export LC_ALL=en_US.utf8" >> /etc/environment
echo "export LC_TYPE=en_US.utf8" >> /etc/environment
echo "export LC_MESSAGES=en_US.utf8" >> /etc/environment
echo "export LC_MEASUREMENT=en_US.utf8" >> /etc/environment
echo "export LC_PAPER=en_US.utf8" >> /etc/environment
echo "export LC_MONETARY=en_US.utf8" >> /etc/environment
echo "export LC_NAME=en_US.utf8" >> /etc/environment
echo "export LC_ADDRESS=en_US.utf8" >> /etc/environment
echo "export LC_NUMERIC=en_US.utf8" >> /etc/environment
echo "export LC_TELEPHONE=en_US.utf8" >> /etc/environment
echo "export LC_IDENTIFICATION=en_US.utf8" >> /etc/environment
echo "export LC_TIME=en_US.utf8" >> /etc/environment

echo "Download and Install XCP-NG Key"
curl -O https://xcp-ng.org/RPM-GPG-KEY-xcpng
rpm --import RPM-GPG-KEY-xcpng
# rpm --import https://xcp-ng.org/RPM-GPG-KEY-xcpng
# curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng https://xcp-ng.org/RPM-GPG-KEY-xcpng

echo "Create repository for xcp-ng"
cat << 'EOF' > /etc/yum.repos.d/xcp-ng.repo
[xcp-ng-base]
name=XCP-ng Base Repository
baseurl=https://updates.xcp-ng.org/8/8.3/base/x86_64/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng

[xcp-ng-updates]
name=XCP-ng Updates Repository
baseurl=https://updates.xcp-ng.org/8/8.3/updates/x86_64/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng
EOF

echo "XCP-ng repositories have been added to /etc/yum.repos.d/xcp-ng.repo"

echo "Install Xen-Tools"
yum repolist
yum -y install blktap vhd-tool qemu-img

echo "XCP-NG repositories configured"
echo "Xen-Tools installed"
echo "Please Logout and then Login to server so locale configuration changes get replected"
