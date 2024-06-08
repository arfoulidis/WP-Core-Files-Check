#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# List of plugins to ignore warnings for
IGNORED_PLUGINS=("wp-rocket" "wp-all-import-pro" "wpai-woocommerce-add-on" "woo-bulk-editor" "revslider" "wp-smart-image-resize-pro" "webexpert-woocommerce-piraeus-payment-gateway" "webexpert-skroutz-xml-feed" "woodmart-core" "wpae-woocommerce-add-on" "wp-all-export-pro" "js_composer")

# Function to check and run wp-cli commands
check_wp_config() {
  local user_home="$1"
  
  # Check if wp-config.php exists in the user's home directory
  if [[ -f "$user_home/wp-config.php" ]]; then
    echo "Found wp-config.php in $user_home"

    # Run wp-cli commands and capture output
    local output=$(su -c "cd $user_home && wp plugin verify-checksums --all 2>&1" "$user")
    local errors=$(echo "$output" | grep -v -E "$(printf "|%s" "${IGNORED_PLUGINS[@]}")")

    # If there are errors, send an email
    if [[ ! -z "$errors" ]]; then
      echo -e "Subject: WP Plugin Verify Checksums Errors\n\nErrors found in $user_home:\n$errors" | sendmail a89@duck.com
    fi
  fi
}

# Loop through all system users
for user in $(cut -d: -f1 /etc/passwd); do
  user_home=$(eval echo "~$user")
  
  # Check if the home directory exists
  if [[ -d "$user_home" ]]; then
    check_wp_config "$user_home"
  fi
done
