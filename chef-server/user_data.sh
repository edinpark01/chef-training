#!/bin/sh

# Retrieve in-line arguments
username=$1
first_name=$2
last_name=$3
password=$4
organization=$5
email=$6


# Install necessary packages
yum update
yum install -y wget which firewalld

chef_home='/opt/chef-server'
chef_server_link="https://packages.chef.io/files/stable/chef-server/12.19.31/el/7/chef-server-core-12.19.31-1.el7.x86_64.rpm"
chef_server_rpm="chef-server-core-12.19.31-1.el7.x86_64.rpm"

# Housekeeping - Create necessary folders
mkdir -p $chef_home
mkdir -p '/apps/chef/'
mkdir -p '/apps/chef/pem_files'

# Download the package from https://downloads.chef.io/chef-server/.
# RHEL7 chef-server-rpm: https://packages.chef.io/files/stable/chef-server/12.19.31/el/7/chef-server-core-12.19.31-1.el7.x86_64.rpm
if [ ! -f "${chef_home}/${chef_server_rpm}" ]; then
    wget $chef_server_link -P $chef_home
fi

# Install chef-server downloaded RPM - ONLY if NOT already installed
if [ ! $( which chef-server-ctl ) ]; then 
    rpm -Uvh ${chef_home}/$chef_server_rpm
    chef-server-ctl reconfigure --accept-license

    # Create an administrator:
    chef-server-ctl user-create \
        $username \
        $first_name $last_name \
        $email \
        $password \
        --filename "/apps/chef/pem_files/${username}.pem"
    
    # Create an organization:
    chef-server-ctl org-create \
        $organization \
        "${organization} INC" \
        --association_user ${username} \
        --filename "/apps/chef/pem_files/${organization}-validator.pem"

    # Innstall the Chef Management Console 
    chef-server-ctl install chef-manage 
    chef-server-ctl reconfigure --accept-license 
    chef-manage-ctl reconfigure --accept-license
fi

# Enables and Starts firewalld service
systemctl enable firewalld  
systemctl start firewalld
systemctl status firewalld

# Enable/Open necessary ports
ports=( 80 443 4321 9683 9463 9090 8000 8983 5432 5672 16379 22 )

for port in "${ports[@]}"; do
    firewall-cmd --zone=public --add-port=${port}/tcp --permanent
done

# Reloads and lists all provisioned ports
echo "Reloading firewall-cmd"
firewall-cmd --reload
echo "Listing all provisioned ports"
firewall-cmd --list-ports