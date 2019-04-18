current_dir = File.dirname(__FILE__)
log_level                :debug
log_location             STDOUT

# cookbook_path
# The sub-directory for cookbooks on the chef-client. 
# This value can be a string or an array of file system locations, 
# processed in the specified order. 
# The last cookbook is considered to override local modifications
cookbook_path            ["#{current_dir}/../cookbooks"]

# node_name:
# May be a username with permission to authenticate to the Chef server OR
# May be the name of the machine from which knife is run.
node_name                "#{ENV['USERNAME']}"  
client_key               "#{current_dir}/#{ENV['USERNAME']}.pem"

# The name of the chef-validator key that is used by the chef-client 
# to access the Chef server during the initial chef-client run
validation_client_name   "#{ENV['ORGANIZATION']}-validator"
validation_key           "#{current_dir}/#{ENV['ORGANIZATION']}-validator.pem"
chef_server_url          "https://chef-server/organizations/#{ENV['ORGANIZATION']}"


cache_type               'BasicFile'
cache_options( :path => "/apps/chef-repo/.chef/checksums" )

