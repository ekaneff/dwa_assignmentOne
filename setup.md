# How to Set Up Wordpress on Digital Ocean with Ubuntu 14.04 with LEMP Stack
#### By Emily Kaneff

##Table of Contents
* [Set up the VPS]()
* [Connecting and Creating Users]()
* [Adding Dependancies]()
* [Adding Wordpress]()
* [Resources]()

## Step One: Set up the VPS

The first step in this whole process is going to be setting up the Virtual Private Server on Digital Ocean. This is done through their clickable interface on their website. 

1. Create a new Droplet on Digital Ocean
2. For this project we will need version 14.04 of Ubuntu, so select the Ubuntu 14.04 image
3. Choose the size acceptable for your application (in this case, use the $5/mo option)
4. Select a datacenter region that is located closest to you. The numbers represent the number of data centers in that region, and the highest number is just the newest one.
5. Additional options are recommended but not required. I suggest selecting Backups to allow yourself to roll back to older versions of your server in case any issues arise.
6. For now, skip over the SSH Keys section. Setting up an SSH Key is a more secure option and will allow for you to not have to enter in a password each time you log in to your server from your machine. 
7. Choose a hostname that makes sense for your project and hit CREATE

## Step Two: Connecting and Creating Users

Now that the server exists on Digital Ocean, you can access it from your machine through an SSH. 

Locate the IP for that server either on the Droplets page of Digital Ocean or in the email associated with your Digital Ocean account (see below).

If you did not set up an SSH Key, you will receive an email containing the information needed for you to access your server. This information will include the IP for the server, the root username and the auto-generated root password. 

> Note: You will be required to change this password immediately upon logging in to the server.

Once you have located the IP and have received your password, you are ready to SSH.

#### Navigate to your terminal

Since you are accessing a VPS, it does not matter from which location on your machine you fire the SSH command.

#### Using the format ```user@host```, run the command: 
```shell
ssh root@[your server IP]
```
From there you will be prompted to enter in the password for their server. Simply paste in the password that was given to you and follow the steps for creating a new one. **Be sure to choose a password that is secure.**

As it stands right now, there is only one user registered for this server, and that is _root_. The root user has a lot of power, so you want to make sure to limit that in some way by adding more users with permissions to ensure the safety of the server. 

#### Create a new user with ```adduser``` and give them sudo permissions with ```usermod```

> Be sure to run these commands as the _root_ user

```shell
adduser [username]             #creates new user with designated username
usermod -aG sudo [username]    #adds user to sudo group
su [username]                  #switches current user to user designated
```

By adding this user to the _sudo_ group, he/she will be able to perform administrative tasks by using ```sudo``` before each command.

You will be prompted with a series of questions, starting with the password you want for this user. Set a strong password for the user, then fill in any additional information that you'd like or you can hit enter to skip through them (they are not required). 

You have now successfully created a new user with administrative permissions. From here, you can begin adding the different dependancies you will need on your server in order to host and serve your Wordpress site.

## Step Three: Adding Dependancies

Before we start adding the different packages the server needs, it is important to remember to do an ```update``` and an ```upgrade``` before anything else.

All of the dependancies will be brought in from Ubuntu's package repositories, which means we can use the ```apt``` suite to install them.

####Perform an ```update``` and ```upgrade```

> You should now be running these commands as the new user created in the previous step

```shell
sudo apt-get update            #Syncs package index files with their sources
sudo apt-get upgrade           #fetches new version of packages already on the machine if made available
sudo apt-get dist-upgrade      #handles changing dependencies with new package versions
```
> Note: ```update``` must be executed first in order for ```upgrade``` to know if there are any updates on the packages installed on the machine

After running these commands, your server is ready now for its packages.

#### Nginx

To actually serve our files to the web browser, we will be implementing a popular web service known as Nginx.  

To install the package, simply run: 

```shell
sudo apt-get install nginx
```
By Default, Ngnix will start running upon installation. This means that you can now enter in your server's IP into your browser window. You you land at the Nginx welcome screen, you have successfully installed Nginx. 

#### MariaDB

To store and manage the site data, we will use a slightly superior alternative to MySQL called MariaDB. 

```shell
sudo apt-get install mariadb-server
```
This installation is a bit more involved, since it requires a few security steps before it can complete.

After the command has run, enter 'Y' to continue on. You will then be asked to enter in a password for the root user of the database. **Use a strong password.**

The basic installation of MariaDB is now complete, but we aren't finished yet. We need to now configure and secure MariaDB for use. Before we do this, you must run

```shell
sudo service mysql stop
```
to stop the service and allow us to make some changes. 

Now we can tell MariaDB to create its directory structure: 

```shell
sudo mysql_install_db
```

Once that completes, you can start the service up again: 

```shell
sudo service mysql start
```

Now we can secure MariaDB a bit by taking out the test databases and the anonymous user it created by default: 

```shell
sudo mysql_secure_installation
```
This will prompt you for your password that you set up during installation. If you are happy with your password, you can enter 'N' when asked to change it. You can then answer with 'Y' for the rest of the questions prompted. 

To enter the MariaDB client, you can enter the command: 

```shell
mysql -p
```
Enter your password and you should be greeted with the MariaDB welcome message. You have now successfully installed MariaDB. 

A few helpful commands to be aware of, also: 

```shell
exit                             #exit the client
sudo service mysql status        #check status 
sudo service mysql restart       #restart MariaDB
```

#### PHP

We need PHP in order to communicate between our server and our database. Nginx does not come with native PHP processing, so we have to install ```php5-fpm``` and tell Nginx to pass PHP requests to the _fpm_ software. 

We will install the _fpm_ software and also a helper package for the database with the command: 

```shell
sudo apt-get install php5-fpm php5-mysql
```

Now that PHP is installed, we need to tell Nginx to look at the processor (fpm) for dynamic content. We do this on the 'server block level' in the configuration file through the command: 

```shell
sudo nano /etc/nginx/sites-available/default
```

Before we make any changes, the upper part of the server object in that file should look like this: 

```shell
	listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /usr/share/nginx/html;
    index index.html index.htm;

    server_name localhost;

    location / {
        try_files $uri $uri/ =404;
    }
```

> Note: There will be commented lines shown in the file on your terminal. What is shown here is with those removed. 

We are only changing certain portions of this server object, so after the changes you should have this in your server object: 

```shell
	listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    root /usr/share/nginx/html;
    index index.php index.html index.htm;

    server_name server_domain_name_or_IP;

    location / {
        try_files $uri $uri/ =404;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
```

> In the \.php$ section, it may be easier to completely remove what is already in there and replace it with the lines above. This way you avoid any chance of leaving any important lines commented or leaving something out.

Save and close the file, and restart the Nginx service with the following command:

```shell
sudo service nginx restart
```

##Step Four: Adding Wordpress

####Create database and database user

Your LEMP stack should now be completely set up and ready for your Wordpress files. Once installation is complete, you will be able to use the Wordpress interface in your browser to manage almost everything for your site. 

The first step in this process is going to be creating and configuring the database. Although we used MariaDB, the commands are still the same. However, one key difference is that MariaDB **is case sensitive**, so make sure you write the commands exactly as they are shown. 

To begin, log in to the instance of MariaDB with the command: 

```shell 
mysql -u root -p
```

Enter in your password for the database that you made during installation. You should now have the SQL command prompt.

From here we can create a new database for out Wordpress site to use. What you name it isn't super important, but it should be easily recognizable. For this example, we can call it ```wordpress```:

```shell
CREATE DATABASE wordpress;
```

>Remember that MariaDB is case sensitive, so making the commands in all caps matters. Also, take note of the semi-colon at the end of the command. This is what ends each SQL statement, and they are required for the command to run.

Now that we have a database, we can create a new user that will have control over the database. Creating a separate database and user for each application is a useful way of keeping project specific data separate from other data stored by MySql. 

You will need to create a username and a password for this user, so make sure to choose something secure:

```shell
CREATE USER [username]@localhost IDENTIFIED BY '[password]';
```
Now that the user exists, we need to make the relationship between that user and our database. We need to tell that database that this user is allowed to have access through this command:

```shell
GRANT ALL PRIVILEGES ON wordpress.* TO [username]@localhost;
```

At this point all the configuration should be set, so we need to just flush the privileges to disk so that the current working instance of MariaDB knows about the change: 

```shell
FLUSH PRIVILEGES;
```

Run ```exit``` to return to the command prompt, and now we can move on to downloading wordpress. 

> You should still be logged in as your sudo user, not the root. 

####Downloading wordpress files and configuring

For downloading, the newest version is always given the same URL, which makes this process fast and easy. We want to download the file into our sudo user's home directory: 

```shell
cd ~
wget http://wordpress.org/latest.tar.gz
```

The application files are downloaded as a compressed, archived directory stored in a file called ```latest.tar.gz```. To get the contents out, run: 

```shell
tar xzvf latest.tar.gz
```
If you run ```ls``` now in the directory you are in, you should see a new directory called ```wordpress``` that contains all the site files. 

We can also now go ahead and download a couple of packages that will allow you to work with images and install/update plugins and components using SSH: 

```shell
sudo apt-get update
sudo apt-get install php5-gd libssh2-php
```
> If you are doing this tutorial all in one go, you don't technically need to do the ```update``` command. However, since we will be downloading new packages, it is a good habit to get into.

We now have all of the files that we need, so we can now begin the configuration process. 

Navigate to the new ```wordpress``` directory so that you will have access to the main configuration file: 

```shell
cd ~/wordpress
```

Wordpress ships with a sample configuration file that has almost everything we need already done for us, so we can simply copy this file into our own config file and use it as the base: 

```shell
cp wp-config-sample.php wp-config.php
```

Open the file so we can make the adjustments we need: 

```shell
nano wp-config.php
```

In this file, the only things we need to change are the ```DB_NAME```, ```DB_USER```, and ```DB_PASSWORD```. Find those parameters in the file and fill in the information we set up during the database installation and configuration: 

```shell
. . .
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', '[username]');

/** MySQL database password */
define('DB_PASSWORD', '[password]');
. . .
```

Save and close the file once those changes have been made. 

####Moving files to document root

In order for the server to find and serve the files for the site, they need to be in a place that the server can see. The default location for the document root for Nginx on Ubuntu 14.04 is ```/usr/share/nginx/html/```, however, we will be setting up a new root in ```/var/www/html/``` to avoid modifying a directory that is controlled by the Nginx package. 

Using the ```rsync``` utility will allow us to preserve permissions, ownership and data integrity. 

To create the new root directory, run:

```shell 
sudo mkdir -p /var/www/html
```
Copy the files over by running: 

```shell
sudo rsync -avP ~/wordpress/ /var/www/html/
```

Navigate to this new document root so we can modify some of the file permissions: 

```shell
cd /var/www/html/
```
As it stands right now, all the files have user and group ownership assigned to our user. This is fine, but the server needs to be able to make adjustments to it's own files and directories as well. 

We can accomplish this by giving the group that the web server runs under group ownership of the files. 

Nginx runs under the group ```www-data```. To give permission to the user for this portion, run: 

```shell
sudo chown -R [username]:www-data /var/www/html/*
```
Next, create a new directory for user uploads: 

```shell
mkdir wp-content/uploads
```

This directory doesn't have ```www-data``` ownership yet, but it should have group writing set already, so to fix that run: 

```shell
sudo chown -R :www-data /var/www/html/wp-content/uploads
```

####Modifying Nginx server blocks

With all the correct permissions set up, we can now move onto configuring Nginx to serve the files correctly.

Using the default server block as the base, we can copy it over to the new one: 

```shell
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/wordpress
```

Now open this new file we made so that we can make some adjustments: 

```shell
sudo nano /etc/nginx/sites-available/wordpress
```

The changes we need to make are minor, but they are: 

```shell 
server {
		root **/var/www/html**;
        index index.php index.html index.htm;

        server [your ip or domain name];

        location / {
                **# try_files $uri $uri/ =404;**
                try_files $uri $uri/ **/index.php?q=$uri&$args;**
        }
      }
```

>Changes are indicated with **. Do not include those in the file. 

Now we need to link this new file to the ```sites-enabled``` directory in order for it to be activated. To do this, run: 

```shell
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/
```

Since the file we just linked will conflict with the old defaults file, simply remove the old file by running: 

```shell
sudo rm /etc/nginx/sites-enabled/default
```
Now to enable the changes, simply restart the web server and PHP processor: 

```shell
sudo service nginx restart
sudo service php5-fpm restart
```
At this point, you are ready to finish the installation through the web interface! Enter in your domain or your server's IP into a web browser and you should be directed to the Wordpress installation page. 

From there you can just follow the directions and then you will have a working instance of Wordpress on your Ubuntu 14.04 droplet!

##Resources

[Initial Server Setup with Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04)

[How To Install Linux, nginx, MySQL, PHP (LEMP) stack on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-ubuntu-14-04)

[How To Install WordPress with Nginx on Ubuntu 14.04](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-nginx-on-ubuntu-14-04)

[How to Install MariaDB 5.5 on Ubuntu 14.04 LTS](https://www.liquidweb.com/kb/how-to-install-mariadb-5-5-on-ubuntu-14-04-lts/)

[apt-get update and upgrade explanation](http://askubuntu.com/questions/222348/what-does-sudo-apt-get-update-do)

[Why to use MariaDB over MySQL Server](https://seravo.fi/2015/10-reasons-to-migrate-to-mariadb-if-still-using-mysql)
