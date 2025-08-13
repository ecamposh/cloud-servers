#!/bin/bash

# Backup existing sources.list
echo "Backing up /etc/apt/sources.list to /etc/apt/sources.list.bak"
cp /etc/apt/sources.list /etc/apt/sources.list.bak || error_exit "Failed to backup sources.list"

# Update sources.list to use archive.debian.org with trusted=yes
echo "Configuring /etc/apt/sources.list to use Debian archive repositories with trusted mode"
cat > /etc/apt/sources.list << EOL
deb [trusted=yes] http://archive.debian.org/debian/ jessie main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian/ jessie main contrib non-free
deb [trusted=yes] http://archive.debian.org/debian-security/ jessie/updates main contrib non-free
deb-src [trusted=yes] http://archive.debian.org/debian-security/ jessie/updates main contrib non-free
EOL
[ $? -eq 0 ] || error_exit "Failed to update sources.list"

# Clear APT cache
echo "Clearing APT cache"
apt-get clean || error_exit "Failed to clear APT cache"

# Update package index
echo "Updating package index"
apt-get update || error_exit "Failed to update package index"

# Perform system upgrade
echo "Performing system upgrade"
apt-get upgrade -y || error_exit "Failed to perform upgrade"
