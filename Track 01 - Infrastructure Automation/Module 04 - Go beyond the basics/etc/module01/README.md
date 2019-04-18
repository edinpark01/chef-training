# What happens when you execute knife bootstrap

Notes from YOUTUBE video: [Beyond Chef Essentials - What Happens During Knife Bootstrap](#https://www.youtube.com/watch?time_continue=625&v=7szFHZRVNCU)

### Knife bootstrap sequence
Normally the information goes from workstation to chef-server, info such as chef-run list and the node contacts the chef-server when it runs the chef-client.
However, during bootstrap we are actually sshing into the node. We use two commands, ssh/scp:

1. ( Workstation -> NODE ) Initial actions:
* SSH to securely log into node
* scp to securly copy files over, the files that are copied over are:
    * chef_server_url: where is the chef-server is locatated
    * validation_client_name: files that are required to prove that node is allowed to communicate with chef-server
    * validation_client_key:

2. ( NODE ) Further OS provisioning 
    1. Install chef-client
    2. Configure chef-client
    3. Run chef-client ( Important )
        1. First time we save/register node details with chef server

3. ( NODE -> Chef Server) Connect with Chef server and register node
    1. Store NODE detail in a PostgreSQL database
    2. Do Indexing - SOLR
        1. Way to search data on server fast 

### chef-client run 
When we install chef-clien we also install all ruby. It is package in something called the Ohai  bus installer which includes
1. All Ruby Language - Used by Chef
2. Chef-clien - Client Application
3. Ohai - System profiler
4. Test Kitchen, and more...

### Key Directories:
1. <b>/etc/chef</b>: 
    1. client.pem
    2. client.rb: Contains client chef configuration information that will use pem file 
2. <b>/var/chef/</b>
    1. backup direcory: backups of files 
    2. cache directory: all cookbooks stores after synchorinzation process
3. <b>/opt/chefdk/</b>
    1. Where the chef tools are installed