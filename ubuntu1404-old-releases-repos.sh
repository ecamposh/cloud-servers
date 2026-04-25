#!/bin/bash

# Configure Ubuntu 14.04 Trusty repositories for old-releases archive

set -e

BACKUP_DIR="/etc/apt/backup_$(date +%Y%m%d_%H%M%S)"
SOURCES_LIST="/etc/apt/sources.list"
CODENAME="trusty"
OLD_RELEASES_URL="http://old-releases.ubuntu.com/ubuntu"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

echo "Backing up existing apt sources"
[ -f "$SOURCES_LIST" ] && cp -a "$SOURCES_LIST" "$BACKUP_DIR/sources.list"

if ls /etc/apt/sources.list.d/*.list >/dev/null 2>&1; then
    cp -a /etc/apt/sources.list.d/*.list "$BACKUP_DIR/"
fi

echo "Disabling existing third-party source list files"
for file in /etc/apt/sources.list.d/*.list; do
    [ -f "$file" ] && mv "$file" "$file.disabled"
done

echo "Writing Ubuntu 14.04 old-releases repositories"
cat > "$SOURCES_LIST" << EOF
deb $OLD_RELEASES_URL $CODENAME main restricted universe multiverse
deb $OLD_RELEASES_URL $CODENAME-updates main restricted universe multiverse
deb $OLD_RELEASES_URL $CODENAME-security main restricted universe multiverse
deb $OLD_RELEASES_URL $CODENAME-backports main restricted universe multiverse

# Source packages, uncomment if needed:
# deb-src $OLD_RELEASES_URL $CODENAME main restricted universe multiverse
# deb-src $OLD_RELEASES_URL $CODENAME-updates main restricted universe multiverse
# deb-src $OLD_RELEASES_URL $CODENAME-security main restricted universe multiverse
# deb-src $OLD_RELEASES_URL $CODENAME-backports main restricted universe multiverse
EOF

echo "Cleaning apt cache"
apt-get clean

echo "Updating apt package lists"
apt-get update

echo "Installing/regenerating locale"
apt-get install -y locales
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "Verifying repositories"
apt-cache policy | head -50

echo "Ubuntu 14.04 Trusty old-releases repositories configured successfully."
echo "Backup stored in: $BACKUP_DIR"
echo "Log out and back in, or run: source /etc/default/locale"
