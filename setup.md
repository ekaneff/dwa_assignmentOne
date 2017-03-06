# Using Ansible to Deploy Wordpress
#### By Emily Kaneff

For this tutorial, I will be showing you briefly how to configure your virtual private server to deploy Wordpress using an automation platform known as Ansible. 

The idea behind Ansible is to make configuring your servers quick and easy, and most importantly portable. You write the automation scripts one time and you can then apply it to as many different servers at a time that you need. 

To begin, you need to install ansible globally on your machine. You can do that with the Homebrew command:

```shell
brew install ansible
```
>Note: If you do not have Homebrew installed, you can find how to do so [here](https://brew.sh/).

One that finishes, download the files from [this](https://github.com/ekaneff/ansible-wordpress) repository and place them in the root of your project folder. 

Open the `hosts` file and place the IP address of your project within that file. Also, under `roles/wordpress/vars`, change the variable `ip` to equal your IP address as well. 

After that is in place, there are only two more steps needed. First, navigate to your project in terminal and run the command: 

```shell
ansible all -m raw -s -a "sudo apt-get -y install python-simplejson" -u root --private-key=~/.ssh/id_ansible -i ./hosts
```

This will install the necessary python package needed to make Ansible run. 

Finally, run the command: 

```shell
ansible-playbook --private-key=~/.ssh/id_ansible -i ./hosts wordpress_role.yml
```

This will begin the Ansible process of running tasks and installing the necessary packages.

>Note: Some tasks may take a few minutes to complete. 

You should now be able to go to the IP of your project and be greeted with the Wordpress installation page. 

>If you would like to install a newer version of wordpress, simply change the variable in the `var` file. 

##Resources
[Ansible Docs on Playbooks](http://docs.ansible.com/ansible/playbooks.html)
