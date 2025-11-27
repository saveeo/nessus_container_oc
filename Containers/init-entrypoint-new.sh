#!/bin/sh
# This script is intended to be run in a privileged initContainer.
# It configures Nessus for Security Center management and prepares the volume for the main container.

set -e

# if [[ ! -d "/opt/nessus" || -n "$(find /opt/nessus -maxdepth 0 -empty 2>/dev/null)" ]]; then
# if [ -d "/opt/nessus" ]; then
#     echo "InitContainer: Nessus found. Copy the base, maybe its updated"
# mkdir -p /opt/nessus
# cp -R /nessus/* /opt/nessus/
# chmod -R g+w /opt/nessus
# chown -R nessus:nessus /opt/nessus

# else
#     if [ -s "/opt/nessus/var/nessus/global.db" ]; then
#     echo "InitContainer: Upgrade Only"
#         cp -aR /nessus/* /opt/nessus/

# fi

if [ -s "/data/nessus/global.db" ]; then
    echo "InitContainer: Nessus data already initialized. Skipping setup."
    # We must still ensure permissions are correct on every run, as they can be
    reset.
    echo "InitContainer: Ensuring correct permissions..."
    # chmod -R g+rwX /opt/nessus
    echo "InitContainer: Permissions verified. Finished successfully."
    exit 0
fi

echo "InitContainer: Nessus data not found. Starting first-time initialization
process."

echo "InitContainer: Copying base files..."
# Use '.' to robustly copy contents of /nessus into /opt/nessus
#cp -aR --preserve=mode,timestamps,xattr /nessus/. /opt/nessus/

echo "InitContainer: Starting nessusd service..."
/opt/nessus/sbin/nessusd --no-root &

echo "InitContainer: Waiting for Nessus to initialize..."
# Wait for the global.db file to be created and non-empty
while [ ! -s "/opt/nessus/var/nessus/global.db" ]; do
    sleep 2
done
echo "InitContainer: Nessus initialized."

check_if_linked=$(
    /opt/nessus/sbin/nessuscli managed --sc --username=admin --password=admin
    # /opt/nessus/sbin/nessuscli managed
    2>&1 || true
)

# Check if the output contains the specific "command not found" error.
if echo "$check_if_linked" | grep -q "Error: Command 'managed' not found"; then
    echo "InitContainer: 'managed' command not found. Assuming Nessus is already
configured. Proceeding."
elif echo "$check_if_linked" | grep -q "will now be restarted"; then
    #
    # output=$(
    #     /opt/nessus/sbin/nessuscli managed --sc --username=admin --password=admin
    #     # /opt/nessus/sbin/nessuscli managed
    #     2>&1 || true
    # )
    echo "InitContainer: Configuration successful."
else
    # If we get here, the command failed with an unexpected error.
    echo "InitContainer: An unexpected error occurred during configuration:" >&2
    echo "$output" >&2
    exit 1
fi

echo "InitContainer: Configuring for Security Center management."
# USERNAME and PASSWORD must be passed as environment variables to the container
# TODO: insecure change it

echo "InitContainer: Stopping nessusd service to finalize configuration..."
#/opt/nessus/sbin/nessus-service -d
pkill -f /opt/nessus/sbin/nessusd || true
# Give the service a moment to shut down cleanly
sleep 5

echo "InitContainer: Setting permissions on /opt/nessus for main container..."
#chown -R nessus:nessus /opt/nessus

# --- Final Step: Copy configured data to the persistent volume ---
echo "InitContainer: Configuration complete. Changing permission on directory"
# Ensure the destination directory exists
# mkdir -p /data
# # Copy all the variable data from the ephemeral location to the PVC
# # The 'cp -a' command preserves permissions
# cp -aR /opt/nessus/ /data/
#
# chown -R nessus:nessus /data
# chmod -R g+rwX /opt/nessus
# chmod o+rx /opt/nessus/var/nessus/CA
# chmod o+rx /opt/nessus/var/nessus/www
# chmod o+rx /opt/nessus/var/nessus/users/admin
# chmod o+rx /opt/nessus/var/nessus/templates/tmp
# chmod o+rx /opt/nessus/var/nessus/templates
# chmod o+rx /opt/nessus/var/nessus/audits

cp -aR /opt/nessus/var /data/
chmod o+rx /data/nessus/CA
chmod o+rx /data/nessus/www
chmod o+rx /data/nessus/users
chmod -R o+rx /data/nessus/users/*
chmod o+rx /data/nessus/templates/tmp
chmod o+rx /data/nessus/templates
chmod o+rx /data/nessus/audits

# ls -alR /data/

# sleep 3

echo "InitContainer: Finished successfully."
