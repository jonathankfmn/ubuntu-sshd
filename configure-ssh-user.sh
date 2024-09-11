#!/bin/bash

# Set default values for SSH_USERNAME and PASSWORD if not provided
: ${SSH_USERNAME:=ubuntu}
: ${PASSWORD:=changeme}

# Check if the user exists
if id -u "$SSH_USERNAME" > /dev/null 2>&1; then
    echo "User $SSH_USERNAME already exists"
else
    # Create the user with a home directory and bash shell
    echo "Creating user $SSH_USERNAME with a home directory and bash shell..."
    useradd -ms /bin/bash -G sudo "$SSH_USERNAME"

    # Set the user's password
    echo "Setting the password for user $SSH_USERNAME..."
    echo "$SSH_USERNAME:$PASSWORD" | chpasswd

    # Set correct ownership and permissions for the user's home directory
    echo "Setting ownership and permissions for /home/$SSH_USERNAME..."
    chown -R "$SSH_USERNAME:$SSH_USERNAME" "/home/$SSH_USERNAME"
    chmod 755 "/home/$SSH_USERNAME"

    echo "User $SSH_USERNAME created with the provided password and sudo rights"
fi

# Add the user $SSH_USERNAME to the sudo group
echo "Adding user $SSH_USERNAME to the sudo group..."
usermod -aG sudo "$SSH_USERNAME"

# Display the groups of the created user
echo "The user $SSH_USERNAME is member of following groups:"
groups "$SSH_USERNAME"


# Set the authorized keys from the AUTHORIZED_KEYS environment variable (if provided)
if [ -n "$AUTHORIZED_KEYS" ]; then
    mkdir -p /home/$SSH_USERNAME/.ssh
    echo "$AUTHORIZED_KEYS" > /home/$SSH_USERNAME/.ssh/authorized_keys
    chown -R $SSH_USERNAME:$SSH_USERNAME /home/$SSH_USERNAME/.ssh
    chmod 700 /home/$SSH_USERNAME/.ssh
    chmod 600 /home/$SSH_USERNAME/.ssh/authorized_keys
    echo "Authorized keys set for user $SSH_USERNAME"
fi

# Start the SSH server
exec /usr/sbin/sshd -D
