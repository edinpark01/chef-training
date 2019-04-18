# Manage a Node with Chef Server

In this module, you wiil:
1. Provision a Chef server, 
2. Bootstrap a node
3. Apply a basic web server configuration. 

You will also practice updating your cookbook, upload it to the Chef server, and see the changes appear on your node. 

As a bonus, you will resolve an error in your configuration and set up chef-client to run periodically.

To update your cookbook you will use a template. A <b>template</b> enables you to write a single, general recipe that's customized for a particular node as the recipe runs. That means you don’t have to write a custom version of your recipe for every node.

You will also run knife ssh to update your node. <b>knife ssh</b> invokes the command you specify over an SSH connection on a node – in our case sudo chef-client. You don't have to specify the run-list because you already set that up when you bootstrap the node. 

<b>Search</b> enables you to run chef-client on multiple nodes at once. 

A <b>role</b> enables you define your node's behavior and attributes based on its function.

That's it for this module. When you're done experimenting, be sure to clean up your environment.