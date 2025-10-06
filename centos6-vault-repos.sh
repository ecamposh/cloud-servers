#!/bin/bash

# Exit on error
set -e

# Variables
BACKUP_DIR="/etc/yum.repos.d/backup_$(date +%Y%m%d_%H%M%S)"
VAULT_REPO_FILE="/etc/yum.repos.d/CentOS-Vault.repo"

# Step 1: Create backup directory for existing repos
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

# Step 2: Create CentOS Vault repository configuration
echo "Configuring CentOS Vault repositories in $VAULT_REPO_BASE"
cat > "$VAULT_REPO_FILE" << 'EOF'
[base]
name=CentOS-6 - Base - Vault
baseurl=http://vault.centos.org/6.10/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[os]
name=CentOS-6 - OS - Vault
baseurl=http://vault.centos.org/6.10/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[updates]
name=CentOS-6 - Updates - Vault
baseurl=http://vault.centos.org/6.10/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

[extras]
name=CentOS-6 - Extras - Vault
baseurl=http://vault.centos.org/6.10/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=1

#[virt]
#name=CentOS-6 - Virt - Vault
#baseurl=http://vault.centos.org/6.10/virt/$basearch/xen-410
#gpgcheck=1
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
#gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization
#enabled=0

[centosplus]
name=CentOS-6 - Plus - Vault
baseurl=http://vault.centos.org/6.10/centosplus/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=0

[fasttrack]
name=CentOS-6 - Fasttrack - Vault
baseurl=http://vault.centos.org/6.10/fasttrack/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=0

[rt]
name=CentOS-6 - Realtime - Vault
baseurl=http://vault.centos.org/6.10/rt/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
enabled=0
EOF

# Step 3: Clean Yum cache
echo "Cleaning Yum cache"
yum clean all

# Step 4: Rebuild Yum cache
echo "Rebuilding Yum cache"
yum makecache

# Step 5: Verify repository configuration
echo "Verifying repository list"
yum repolist

# Step 6: Change Locale
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

echo "CentOS Vault repositories configured successfully."
echo "Backup of old repos is stored in $BACKUP_DIR"
echo "Please Logout and then Login to server so locale configuration changes get replected"
