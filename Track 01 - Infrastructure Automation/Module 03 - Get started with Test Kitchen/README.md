# Get Started with Test Kitchen
Test Kitchen enables you to run your cookbooks in a temporary environment that resembles production. With Test Kitchen, you confirm that things are workiung before you deploy your code to a test, preproduction, or production environment. Many users incorporate this kind of local development as part of their overall Chef Workflow.

### Apply a cookbook locally
1. Create the Test Kitchen instance

Here you will provision a virtual machine to server as your test environment. This is the `kitchen create` step in our workflow.

2. Apply the learn_chef_httpd cookbook to your Test Kitchen instance by using `kitchen converge` command.
> We use the term converge to describe the process of bringing a system closer to its desired state. 
> When you see the word converge, think test and repair.

3. Verify that your Test Kitchen instance is configured as expected
> In practice, you typically write automated tests that verify whether your instance is configured as you expect. Having automated 
> tests enables you to quickly verify that your configuration works as you add features to your cookbook. In fact, many Chef users 
> take a test-driven approach, where you write your tests first before you write any Chef code.

Run the following command to verify the contents of your web server's home page.
```
kitchen exec -c 'curl localhost'
```

4. Delete the Test Kitchen instance

We're all done with our virtual machine, so now run the `kitchen destroy` command to delete it.


