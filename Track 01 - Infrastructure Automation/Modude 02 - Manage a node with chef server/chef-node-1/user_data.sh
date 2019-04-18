chef_server_ip=$1

# Node needs to be able to communicate with chef-server
echo "${chef_server_ip}     chef-server" >> /etc/hosts
