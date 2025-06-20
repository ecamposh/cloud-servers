#!/bin/bash

# Set default locale to en_US.UTF-8
echo #######################################
echo "Setting default locale to en_US.UTF-8"
echo #######################################

# Create or update the /etc/default/locale file
sudo bash -c 'cat > /etc/default/locale <<EOF
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF'

# Regenerate locales
sudo locale-gen

# Verify the settings
locale

echo #######################################
echo "Locale settings updated successfully."
echo #######################################
