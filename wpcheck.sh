#!/bin/bash

# Define the list of plugins to ignore warnings
IGNORED_PLUGINS=("wp-rocket" "wp-all-import-pro" "wpai-woocommerce-add-on" "woo-bulk-editor" "revslider" 
                 "wp-smart-image-resize-pro" "webexpert-woocommerce-piraeus-payment-gateway" 
                 "webexpert-skroutz-xml-feed" "woodmart-core" "wpae-woocommerce-add-on" 
                 "wp-all-export-pro" "js_composer" "gp-premium")

# Get a list of all WordPress directories in /home/
WORDPRESS_DIRS=$(find /home/ -type f -name "wp-config.php" -exec dirname {} \;)

# Loop through each WordPress directory
for WP_DIR in $WORDPRESS_DIRS; do
    # Get the current user for the WordPress directory
    USER=$(stat -c '%U' "$WP_DIR")
    
    # Print the user and directory being processed
    echo "Processing WordPress installation for user $USER in directory $WP_DIR"

    # Run wp core verify-checksums for the current directory and user
    OUTPUT=$(sudo -u $USER -i -- wp core verify-checksums --path="$WP_DIR" 2>&1)

    # Filter out ignored plugin warnings
    for PLUGIN in "${IGNORED_PLUGINS[@]}"; do
        OUTPUT=$(echo "$OUTPUT" | grep -v "$PLUGIN")
    done

    # Print the output of the wp command
    echo "$OUTPUT"

    # Check if there are any errors
    if echo "$OUTPUT" | grep -q "Warning\|Error"; then
        # Print errors to the terminal
        echo "Errors found for user $USER in directory $WP_DIR:"
        echo "$OUTPUT"
        echo "----------------------------------------"
    else
        echo "No errors found for user $USER in directory $WP_DIR."
        echo "----------------------------------------"
    fi
done
