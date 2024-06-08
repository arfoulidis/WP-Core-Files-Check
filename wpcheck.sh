#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Loop through all system users
for user in $(cut -d: -f1 /etc/passwd); do
    # Skip root and system users
    if [ "$user" == "root" ] || [ "$user" == "nobody" ]; then
        continue
    fi

    # Check if the user's home directory exists
    if [! -d "/home/$user" ]; then
        continue
    fi

    # Check if the user has a WordPress installation
    if [! -f "/home/$user/public_html/wp-config.php" ]; then
        continue
    fi

    # Run WordPress commands as the user
    su -c "cd /home/$user/public_html && wp plugin verify-checksums --all && wp plugin verify-checksums --all" "$user"

    # Check if there were errors
    if [ $? -ne 0 ]; then
        # Send email with error details
        echo "Errors found in $user's WordPress installation." | mail -s "WordPress Plugin Checksum Errors" a89@duck.com
    fi
done