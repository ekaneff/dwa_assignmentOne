# Using Ansible to Deploy Wordpress
#### By Emily Kaneff

For this tutorial, I will be showing you briefly how to configure your virtual private server to deploy Wordpress using an automation platform known as Ansible. 

The idea behind Ansible is to make configuring your servers quick and easy, and most importantly portable. You write the automation scripts one time and you can then apply it to as many different servers at a time that you need. 

To begin, you need to install ansible globally on your machine. You can do that with the Homebrew command:

```shell
brew install ansible
```
>Note: If you do not have Homebrew installed, you can find how to do so [here](https://brew.sh/).

Once that finishes, navigate to your project directory. In here, you will need to begin by making a `hosts` file that will contain the IP addresses of the servers 





<a name="resources"></a>
##Resources
[Ansible Docs on Playbooks](http://docs.ansible.com/ansible/playbooks.html)
