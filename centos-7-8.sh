#!/bin/bash
  
# Define the new base URLs
appstream_baseurl="http://vault.centos.org/\$contentdir/\$releasever/AppStream/\$basearch/os/"
baseos_baseurl="http://vault.centos.org/\$contentdir/\$releasever/BaseOS/\$basearch/os/"
extras_baseurl="http://vault.centos.org/\$contentdir/\$releasever/extras/\$basearch/os/"
 
# Define the repo file paths
appstream_repo_path="/etc/yum.repos.d/CentOS-Linux-AppStream.repo"
baseos_repo_path="/etc/yum.repos.d/CentOS-Linux-BaseOS.repo"
extras_repo_path="/etc/yum.repos.d/CentOS-Linux-Extras.repo"
 
# Create a backup of the original repo files
backup_suffix=".bak"
backup_appstream_repo_path="$appstream_repo_path$backup_suffix"
backup_baseos_repo_path="$baseos_repo_path$backup_suffix"
backup_extras_repo_path="$extras_repo_path$backup_suffix"
 
# Modify the repo files with the new base URLs
sed -i "s|baseurl=.*|baseurl=$appstream_baseurl|" "$appstream_repo_path"
sed -i "s|baseurl=.*|baseurl=$baseos_baseurl|" "$baseos_repo_path"
sed -i "s|baseurl=.*|baseurl=$extras_baseurl|" "$extras_repo_path"
 
# Set locale system timing to UTC
echo "export LANGUAGE=en_US.UTF-8" >> /etc/environment
echo "export LC_ALL=en_US.UTF-8" >> /etc/environment
echo "export LC_MEASUREMENT=en_US.UTF-8" >> /etc/environment
echo "export LC_PAPER=en_US.UTF-8" >> /etc/environment
echo "export LC_MONETARY=en_US.UTF-8" >> /etc/environment
echo "export LC_NAME=en_US.UTF-8" >> /etc/environment
echo "export LC_ADDRESS=en_US.UTF-8" >> /etc/environment
echo "export LC_NUMERIC=en_US.UTF-8" >> /etc/environment
echo "export LC_TELEPHONE=en_US.UTF-8" >> /etc/environment
echo "export LC_IDENTIFICATION=en_US.UTF-8" >> /etc/environment
echo "export LC_TIME=en_US.UTF-8" >> /etc/environment
echo "export LANG=en_US.UTF-8" >> /etc/environment
 
# Module yaml error: Unexpected key in data: static_context [line 9 col 3]
dnf -y upgrade libmodulemd
 
# Update CentOS repository list
yum repolist
 
# Install redhat LSB headers
yum -y install redhat-lsb-core
 
# Install needed packages and tools
yum install -y git curl vim wget
