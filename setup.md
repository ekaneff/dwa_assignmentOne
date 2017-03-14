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

## Using Vagrant for Local Environment

Ansible does a fantastic job of setting up the required environment needed to handle our Wordpress application on the server side, but what about when we want to test our project locally? Well, we still need all the appropriate dependancies such as Nginx, PHP, and a database. So instead of installing all those things globally on our machine, we can create little virtual machines that have environments that mirror the environment on the server. 

To do this, there is a `Vagrantfile` in this repository that talks to a `bootstrap.sh` provisions file that will go through and create a virtual machine and install Git, Nginx, PHP and Maria with a user and permissions. It also specifies a private network that you can open your project on in your browser. 

In order for this to work properly, you need to have Virtual Box installed. You can go ahead and download this program [here](https://www.virtualbox.org/wiki/Downloads). 

You also need to have Vagrant installed globally on your machine. You can follow the download instructions [here](https://www.vagrantup.com/).

Once both of those things are on your machine, you can navigate to your project's root directory and run the command: 

```shell
vagrant up
```

> The install may take a few minutes. 

Once it finishes, you should be able to pull up the private network ip `172.16.0.15` in your browser, and you'll be greeted with the Wordpress install page. 

##Resources
[Ansible Docs on Playbooks](http://docs.ansible.com/ansible/playbooks.html)
