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

cd
# Navigate to home directory and log a message
cd $user_home && echo "correct till this step" >>/var/log/main-data.log 2>&1

export AWS_REGION=ap-south-1

git clone https://github.com/ManoharShetty507/ansible-playbook-k8s-installation.git

# Define the inventory file
INVENTORY_FILE="ansible-playbook-k8s-installation/inventories/inventory.ini"

# Fetch the bastion host public IP
log "Fetching Bastion IP"
BASTION_IP=$(aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Name,Values=bastion" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

# Check if the IP is fetched successfully
if [ -z "$BASTION_IP" ]; then
  log "Failed to fetch Bastion IP"
  exit 1
fi
log "Bastion IP: $BASTION_IP"

# Fetch the master host public IP
log "Fetching Master IP"
MASTER_IP=$(aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Name,Values=master" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

# Check if the IP is fetched successfully
if [ -z "$MASTER_IP" ]; then
  log "Failed to fetch Master IP"
  exit 1
fi
log "Master IP: $MASTER_IP"

# Function to update or add entries
update_entry() {
  local section=$1
  local host=$2
  local ip=$3

  log "Updating entry: Section: $section, Host: $host, IP: $ip"

  # Ensure the section header exists
  if ! grep -q "^\[$section\]" "$INVENTORY_FILE"; then
    log "Section $section not found. Adding section header."
    echo -e "\n[$section]" | sudo tee -a "$INVENTORY_FILE" >/dev/null
  fi

  # Remove existing entry if it exists
  sudo sed -i "/^\[$section\]/,/^\[.*\]/{/^$host ansible_host=.*/d}" "$INVENTORY_FILE"

  # Add or update the entry
  sudo sed -i "/^\[$section\]/a $host ansible_host=$ip" "$INVENTORY_FILE"
}

# Update entries for bastion and master
update_entry "local" "bastion" "$BASTION_IP"
update_entry "master" "master" "$MASTER_IP"

log "Script execution completed successfully"

# Fetch the Load Balancer IP address
LOADBALANCER_IP=$(aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Name,Values=loadbalancer" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

# Verify that we fetched an IP address
if [ -z "$LOADBALANCER_IP" ]; then
  echo "Failed to fetch Load Balancer IP address."
  exit 1
fi

# Correct path to the YAML file
FILE_PATH="/home/ansible-user/ansible-playbook-k8s-installation/roles/init-master/defaults/main.yaml"

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "File not found: $FILE_PATH"
  exit 1
fi

# Use sed to update the IP address in the YAML file
sed -i.bak "s/^LOAD_BALANCER_IP:.*/LOAD_BALANCER_IP: ${LOADBALANCER_IP}/" "$FILE_PATH"
# Confirm the update
echo "Updated LOADBALANCER_IP to ${LOADBALANCER_IP} in $FILE_PATH"
