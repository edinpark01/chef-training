# Retrieve command line arguments
full_name=$1
email=$2
server_ip=$3
username=$4
organization=$5

yum update -y 
yum -y install ntp ntpdate wget which git tzdata scp

if [ ! -f /apps/downloads/$chefdk ]; then
    mkdir -p /apps/downloads
    chefdk="chefdk-3.8.14-1.el7.x86_64.rpm"
    wget "https://packages.chef.io/files/stable/chefdk/3.8.14/el/7/${chefdk}" -P /apps/downloads
    rpm -Uhv /apps/downloads/$chefdk
fi

echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'export TZ="America/New_York"'                 >> /home/vagrant/.bash_profile
echo "export USERNAME=${username}"                  >> /home/vagrant/.bash_profile
echo "export ORGANIZATION=${organization}"          >> /home/vagrant/.bash_profile
source ~/.bash_profile 

git config --system user.name $full_name 
git config --system user.email $email

echo "${server_ip}     chef-server" >> /etc/hosts

# Create the Chef repository
if [ ! -d "/apps/chef-repo" ]; then
    chef generate repo /apps/chef-repo
    mkdir -p /apps/chef-repo/.chef
    echo '.chef' >> /apps/chef-repo/.gitignore
    cp -r /apps/workstation_conf/* /apps/chef-repo/.chef
fi

# Tutorial Instructions
if [ ! -d "/apps/learn-chef/.chef" ]; then
    mkdir -p /apps/learn-chef/.chef
    cp -r /apps/workstation_conf/* /apps/learn-chef/.chef
    mkdir -p /apps/learn-chef/cookbooks
    git clone https://github.com/learn-chef/learn_chef_httpd.git  # Clone demo chef cookbook
    knife cookbook upload learn_chef_httpd  # Upload cookbook into server
    knife cookbook list  # Retrieve a list of cookbooks avaiable at server
fi

