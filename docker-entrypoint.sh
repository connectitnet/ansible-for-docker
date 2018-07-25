#!/bin/bash

# This won't be executed if keys already exist (i.e. from a volume)
ssh-keygen -A

# Loop through ANSIBLE_USERS and add them if they don't already exist
IFS=, read -ra users <<< "$ANSIBLE_USERS"
COUNTER=0
for username in "${users[@]}"
do
    uid=$[COUNTER + 1000]
    id -u $username &>/dev/null || adduser -D -u $uid -H -s /usr/bin/fish $username
    mkdir -p /home/$username/.ssh
    chmod 0700 /home/$username
    touch /home/$username/.ssh/authorized_keys
    chmod 0600 /home/$username/.ssh/authorized_keys
    
    # Chown home folder (if mounted as a volume for the first time)
    chown -R $username:$username /home/$username

    declare ANSIBLE_${username}_PWD
    declare ANSIBLE_${username}_PWD_FILE
    user_passwd_var=ANSIBLE_${username}_PWD
    user_passwd_file_var=ANSIBLE_${username}_PWD_FILE
    
    if [[ -z "${!user_passwd_file_var}" ]]; then
        password=$(echo ${!user_passwd_var} | base64 -d) 
        echo "$username:$password" | chpasswd
    else
        password=$(cat ${!user_passwd_file_var})
        echo "$username:$password" | chpasswd
    fi
    

    COUNTER=$[COUNTER + 1]
done

# Run sshd on container start
exec /usr/sbin/sshd -D -e