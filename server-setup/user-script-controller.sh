#!/bin/bash

sudo su -

# User creation
user_name="ansible-user"
user_home="/home/$user_name"
user_ssh_dir="$user_home/.ssh"

# Check if the user already exists
if id "$username" &>/dev/null; then
    echo "User $username already exists."
    exit 1
fi

# Create the user
sudo adduser --disabled-password --gecos "" "$user_name"

# Inform user creation success
echo "User $user_name has been created successfully."

# Add user to sudoer group
echo "ansible-user ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansible-user

# Switch to user from root
su - ansible-user

# Install AWS CLI
sudo apt-get update -y
sudo apt-get install -y awscli
# sudo apt install python3-pip


# Install ansible
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y
sudo apt install ansible -y


# Create .ssh directory if not exists
mkdir -p $user_ssh_dir
chmod 700 $user_ssh_dir

# Generate SSH key pair if not exists
if [ ! -f "$user_ssh_dir/id_rsa" ]; then
    ssh-keygen -t rsa -b 4096 -f $user_ssh_dir/id_rsa -N ""
fi

chown -R $user_name:$user_name $user_home

# Delete existing public key file in S3 bucket if exists
aws s3 rm s3://my-key/server.pub
# if aws s3 ls s3://my-key1/server.pub; then
#    aws s3 rm s3://my-key1/server.pub
#fi

# Upload public key to S3 bucket with a custom name
aws s3 cp $user_ssh_dir/id_rsa.pub s3://my-key/server.pub 

#logi =n into user
user_name="ansible-user"
user_home="/home/$user_name"
user_ssh_dir="$user_home/.ssh"
ssh_key_path="$user_ssh_dir/authorized_keys"

mkdir -p $user_ssh_dir
chmod 700 $user_ssh_dir

aws s3 cp s3://my-key/server.pub $ssh_key_path
chmod 600 $ssh_key_path
chown -R $user_name:$user_name $user_home


