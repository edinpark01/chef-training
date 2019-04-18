# Retrieve command line arguments
full_name=$1
email=$2
chef_server_ip=$3
username=$4
organization=$5
node_ip=$6

yum update -y 
yum -y install ntp ntpdate wget which git tzdata

if [ ! -f /apps/downloads/$chefdk ]; then
    mkdir -p /apps/downloads
    chefdk="chefdk-3.8.14-1.el7.x86_64.rpm"
    wget "https://packages.chef.io/files/stable/chefdk/3.8.14/el/7/${chefdk}" -P /apps/downloads
    rpm -Uhv /apps/downloads/$chefdk
fi

# Sets up envirtonment variables
echo 'export PATH="/opt/chefdk/embedded/bin:$PATH"' >> /home/vagrant/.bash_profile
echo 'export TZ="America/New_York"'                 >> /home/vagrant/.bash_profile
echo "export USERNAME=${username}"                  >> /home/vagrant/.bash_profile
echo "export ORGANIZATION=${organization}"          >> /home/vagrant/.bash_profile
source ~/.bash_profile 

# Configure git
git config --system user.name $full_name 
git config --system user.email $email

# Adds server and node ips to known hosts file
echo "${chef_server_ip}     chef-server" >> /etc/hosts
echo "${node_ip}       chef-node-1" >> /etc/hosts

# Create the Chef repository
if [ ! -d "/apps/chef-repo" ]; then
    chef generate repo /apps/chef-repo
    mkdir -p /apps/chef-repo/.chef
    echo '.chef' >> /apps/chef-repo/.gitignore
    cp -r /apps/workstation_conf/* /apps/chef-repo/.chef
fi

# Tutorial | UPLOAD Cookbook to chef-server
if [ ! -d "/apps/learn-chef/.chef" ]; then
    echo "==> Uploading learn-chef_httpd recipe to chef-server"

    mkdir -p /apps/learn-chef/.chef
    cp -r /apps/workstation_conf/* /apps/learn-chef/.chef
    mkdir -p /apps/learn-chef/cookbooks
    git clone https://github.com/learn-chef/learn_chef_httpd.git \  # Clone demo chef cookbook
              /apps/learn-chef/cookbooks/  
    knife ssl fetch
    knife ssl status
    knife cookbook upload learn_chef_httpd                          # Upload cookbook into server

    # Bootstrap a chef node
    cd /apps/learn-chef
    knife  \
        bootstrap chef-node-1 \     # hostname
        --ssh-port 22 \             # 22 if from guest-to-guest | N if from host-to-guest
        --ssh-user vagrant \
        --sudo --identity-file /apps/learn-chef/pems/chef-node-1/private_key \
        --node-name chef-node-1 \
        --run-list 'recipe[learn_chef_httpd]'
    # Bootstrap keypoints
    #   You ran knife bootstrap to associate your node with the Chef server and do an initial check-in. 
    #   Bootstrapping is a one-time process. The knife ssh command enables you to update your node's
    #   configuration when your cookbook changes
fi

# Tutorial | Run chef-client periodically
# Berkshelf => Tools that helps you resolve cookbook dependencies [ comes with ChefDK ]
#           => Retrieve the cookbook that your cookbook depends on
#           => Upload your cookbooks to your Chef server
if [ -f /apps/learn-chef/Berksfile ]; then
    # Our Berksfile specifies that:
    #   => pull cookbooks from the public Chef Supermarket server [ may be from private server ]
    #   => we want the chef-client cookbook
    echo "source 'https://supermarket.chef.io'" >> Berksfile
    echo "cookbook 'chef-client'"               >> Berksfile

    # Berkshelf downloads the chef-client cookbook and its dependent cookbooks to the ~/.berkshelf/cookbooks directory.
    cd /apps/learn-chef
    berks install
    knife cookbook list  # list cookbooks available at chef server
fi

# Tutorial | Create a Role
# How often chef-client is run is controlled by two node attributes:
#   node['chef_client']['interval'] – interval specifies the number of seconds between chef-client runs. 
#                                     The default value is 1,800 (30 minutes).
#   node['chef_client']['splay']    – splay specifies a maximum random number of seconds that is added to the interval. 
#                                     Splay helps balance the load on the Chef server by ensuring that many chef-client 
#                                     runs are not occurring at the same interval. The default value is 300 (5 minutes).
#
# Roles enable you to focus on the function your node performs collectively rather than each of its individual components 
# (its run-list, node attributes, and so on). For example, you might have a web server role, a database role, or a 
# load balancer role. 
# 
# Roles are stored as objects on the Chef server. To create a role, you can use the knife role create command. Another 
# common way is to create a file (in JSON format) that describes your role and then run the knife role from file command 
# to upload that file to the Chef server. The advantage of creating a file is that you can store that file in a version 
# control system such as Git.
if [ -d /apps/learn-chef/roles ]; then
    mkdir -p /apps/learn-chef/roles

    # This file defines the web role. 
    #   1. Sets the required interval splay attributes
    #   2. Sets the run-list to contain the 
    #       a. chef-client cookbook
    #       b. learn_chef_httpd cookbook.
    echo '
    {
        "name": "web",
        "description": "Web server role.",
        "json_class": "Chef::Role",
        "default_attributes": {
            "chef_client": {
                "interval": 300,
                "splay": 60
            }
        },
        "override_attributes": {},
        "chef_type": "role",
        "run_list": [
            "recipe[chef-client::default]",
            "recipe[chef-client::delete_validation]",
            "recipe[learn_chef_httpd::default]"
        ],
        "env_run_lists": {}
    }' >> /apps/learn-chef/roles/web.json

    # Run the following knife role from file command to upload your role to the Chef server.
    knife role from file roles/web.json

    # Set our node's run-list
    knife node run_list set chef-node-1 "role[web]"

    # Verify that the role got assigned to our node
    knife node show chef-node-1 --run-list

    # Run Chef-Client: The command below will apply role:web to all nodes that has it assigned to them
    knife ssh 'role:web' 'sudo chef-client' \
        --ssh-user vagrant \
        -i  /apps/learn-chef/pems/chef-node-1/private_key \

    # Get a brief summary of the nodes on our Chef Server
    knife status 'role:web' --run-list
fi

# Clean up environnment
# To delete node ( node that is managed by chef-server ) from chef-server:  
#       knife node delete << node name >>
#
# To delete client ( node allowed to make api call to server ) from chef-server:
#       knife client delete << client name >>
#
# To delete cookbook from chef server
#       knife cookbook delete << cookbook name >>
#
# To delete the role from the Chef server
#       knife role delete << role name >>
#
# Delete the RSA private key from your node
#       sudo rm /etc/chef/client.pem