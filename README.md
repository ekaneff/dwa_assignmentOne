# Deploying to Wordpress with SCP

SCP stands for Secure Copy and is a way of copying files to, from, or between different hosts. 

For this tutorial, I will be walking you through how to use SCP to transfer files from your local machine to a virtual private server. More specifically, I will be transferring a favicon file into a Wordpress project. However, the concepts can be applied to other types of files as well for whatever sort of file transfer you need to do for your specific project. 

This tutorial assumes you already have a VPS up and running with Wordpress installed. If you do not have this, you can follow the tutorial found in [setup.md](https://github.com/ekaneff/dwa_assignmentOne/blob/master/setup.md) to get that set up.


##Table of Contents

* [Create the Icon](#Step-One:-Create-the-Icon)
* [SCP]()
* [SSH and Nano Header File]()


###Step One: Create the Icon

The first thing you need to do to begin this process is create a favicon file. You can create your own or use the search option on this [website](http://www.favicon-generator.org/). 

###Step Two: SCP

Once you have an icon made, download it and place it on your local machine somewhere that is easily accessible. 

>For this tutorial, I recommend placing the file on your desktop so that it is easy to find in terminal. Also note that you should be running the SCP commands locally as your computer user, not inside your server. 

Open terminal and navigate to the location of the file: 

```shell
cd ~/Desktop
```

From there, you can run the SCP command: 

```shell 
scp favicon.ico [username]@[VPS domain or IP]:/var/www/html/wp-content/uploads
```

A quick break down of what this command is doing: 

* The first argument after ```scp``` is the file or files you are transferring. In this example we are only transferring one file and it is on the root of the directory we are in, so no file path was needed. Alternative ways that could look would be ```/some/file/path/favicon.ico``` or ```./*``` for all files in a directory. 
* The second argument is broken down into two parts: 
	* ```[username]@[VPS domain or IP]``` is how you log in to the VPS. You will need to use the user name for the user that has sudo privileges, and then specify either the domain name or the IP address associated with your server.
	* ```/var/www/html/wp-content/uploads``` is where you specify the file path on the VPS that you want the transferred file/s to go. In this case, we are directing the files to a folder in the document root of the Wordpress project we set up in the set up tutorial. This path needs to be whatever location your server is watching to serve it's files. 

If the SCP was successful, you should see a little ```100%``` on the right side of your terminal window. 

###Step Three: SSH and Nano Header File

Now that the file transfer was successful, we can SSH into the server and make the final additions needed to get this favicon to show up. 

To SSH into the server, run: 

```shell
ssh [username]@[domain or IP]
```

Enter in the password associated with the user you log in as. 

Once in the server, you can double check that the file transferred correctly by running the commands: 

```shell
 cd /var/www/html/wp-content/uploads
 ls
```

This will change your current directory to the one where we sent the file, and then it will display all the files and directories within that directory. If the SCP was successful, you should see ```favicon.ico``` appear after the ```ls``` command. 

Next, in order to get the favicon to appear on the site, we need to had a ```<link />``` tag into the head of the site. This is found in the ```header.php``` file which is located in the theme. 

To navigate to this file, run the command: 

```shell
sudo nano /var/www/html/wp-content/themes/twentyseventeen/header.php
```
> Remember that if you are working with your own Wordpress files, your theme folder could have a different name. Be sure that you are targeting the correct directory for your project.

Once you are in this file, insert the following line directly after the opening ```<head>``` tag:

```shell
<link rel="icon" href="[server domain or IP]/wp-content/uploads/favicon.ico">
```

>Again, be sure that the domain/IP and file path is correct for your project if you did not follow along through [setup.md](https://github.com/ekaneff/dwa_assignmentOne/blob/master/setup.md).

Save the file and return to the command prompt. 

If everything is correct, you should now be able to visit your site in the browser and see your little favicon appear in the tab bar! 

>If you do not see your icon, there could be an issue with the file paths that were used. Also try clearing the cache on your browser and refreshing the page as sometimes that may cause issues. 


###Resources

[http://www.hypexr.org/linux_scp_help.php]()

[https://serversforhackers.com/video/deploying-with-scp](https://serversforhackers.com/video/deploying-with-scp)

[https://docs.nexcess.net/article/how-to-add-favicons-to-wordpress.html](https://docs.nexcess.net/article/how-to-add-favicons-to-wordpress.html)

[http://www.favicon-generator.org/](http://www.favicon-generator.org/)