#!/bin/bash

# This script fixes CentOS 7 EOL repos changing from 'mirror.rackspace.com' to 'vault.centos.org/7.9.2009', sets up XCP-ng 7.6 repositories,
# imports the GPG key, and installs blktap, qemu, vhd-tool.
# Run as root. Includes commented fixes for GPG import and repo file download issues.

# Changes all repos extensions to .bak except CentOS-Vault.repo and xcp
# ls *.repo | egrep -v 'CentOS-Vault.repo|xcp' | xargs -I {} sh -c 'mv "$1" "${1%.repo}.bak"' _ {}

# Deletes all repos except CentOS-Vault.repo, backup and xcp
# ls | egrep -v 'CentOS-Vault.repo|backup|xcp' | xargs rm -rf

set -e  # Exit on error

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

# Variables
BACKUP_DIR="/etc/yum.repos.d/backup_$(date +%Y%m%d_%H%M%S)"
VAULT_REPO_FILE="/etc/yum.repos.d/CentOS-Vault.repo"

# Create backup directory for existing repos
echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Move existing .repo files to backup directory
if ls /etc/yum.repos.d/*.repo > /dev/null 2>&1; then
    echo "Moving existing .repo files to $BACKUP_DIR"
    mv /etc/yum.repos.d/*.repo "$BACKUP_DIR" || {
        echo "Error moving .repo files. Exiting."
        exit 1
    }
else
    echo "No .repo files found in /etc/yum.repos.d/"
fi

# Disable any remaining repos by setting enabled=0
for file in /etc/yum.repos.d/*.repo; do
    if [[ -f "$file" ]]; then
        echo "Disabling repos in $file"
        sed -i 's/enabled=1/enabled=0/g' "$file"
    fi
done

# Create CentOS Vault repository configuration
echo "Configuring CentOS Vault repositories in $VAULT_REPO_BASE"
cat > "$VAULT_REPO_FILE" << 'EOF'
[base]
name=CentOS-7 - Base - Vault
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[os]
name=CentOS-7 - OS - Vault
baseurl=http://vault.centos.org/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[updates]
name=CentOS-7 - Updates - Vault
baseurl=http://vault.centos.org/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[extras]
name=CentOS-7 - Extras - Vault
baseurl=http://vault.centos.org/7.9.2009/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1

[centosplus]
name=CentOS-7 - Plus - Vault
baseurl=http://vault.centos.org/7.9.2009/centosplus/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0

[fasttrack]
name=CentOS-7 - Fasttrack - Vault
baseurl=http://vault.centos.org/7.9.2009/fasttrack/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0

[rt]
name=CentOS-7 - Realtime - Vault
baseurl=http://vault.centos.org/7.9.2009/rt/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=0
EOF


echo "Create repository for xcp-ng"
cat << 'EOF' > /etc/yum.repos.d/xcp-ng.repo
[xcp-ng-base]
name=XCP-ng Base Repository
baseurl=https://updates.xcp-ng.org/7/7.6/base/x86_64/
enabled=1
gpgcheck=1
#repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng

[xcp-ng-updates]
name=XCP-ng Updates Repository
baseurl=https://updates.xcp-ng.org/7/7.6/updates/x86_64/
enabled=1
gpgcheck=1
#repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng

#[xcp-ng-extras]
#name=XCP-ng Extras Repository
#baseurl=https://updates.xcp-ng.org/7/7.6/extras/x86_64/
#enabled=0
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng

#[xcp-ng-updates_testing]
#name=XCP-ng Updates Testing Repository
#baseurl=https://updates.xcp-ng.org/7/7.6/updates_testing/x86_64/
#enabled=0
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng

#[xcp-ng-extras_testing]
#name=XCP-ng Extras Testing Repository
#baseurl=https://updates.xcp-ng.org/7/7.6/extras_testing/x86_64/
#enabled=0
#gpgcheck=1
#repo_gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng
EOF

echo "XCP-ng repositories have been added to /etc/yum.repos.d/xcp-ng.repo"

echo "Download and Import XCP-NG key"
#curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng https://xcp-ng.org/RPM-GPG-KEY-xcpng
curl -O https://xcp-ng.org/RPM-GPG-KEY-xcpng
rpm --import RPM-GPG-KEY-xcpng
#gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-xcpng
#rpm --rebuilddb

echo "Install Xen-Tools"
yum repolist
yum -y install blktap vhd-tool qemu-img

echo "CentOS Vault repositories configured"
echo "XCP-NG repositories configured"
echo "Xen-Tools installed"
echo "Please Logout and then Login to server so locale configuration changes get replected"
