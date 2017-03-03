# Deploying to Wordpress with Git Hooks

For this tutorial, I will be walking you through how to deploy to a virtual private server using Git Hooks. Within that, we will also be implementing a unit test that will happen before a commit occurs, as well as proper git feature branch workflow.


This tutorial assumes you already have a VPS up and running with Wordpress installed. If you do not have this, you can follow the tutorial found in [setup.md](https://github.com/ekaneff/dwa_assignmentOne/blob/master/setup.md) to get that set up. It also assumes you have a local repository already initialized with the Wordpress files already downloaded. You should have a master, release, and feature branches to work from. 

>Note, for this tutorial you are not required to have a local environment spun up. Just simply have the files downloaded to demonstrate how they move throughout the pipeline. 

##Table of Contents

* Creating humans.txt
* Implementing Unit Testing
* Configuring Pre-Commit Hook
* Configuring Post-Merge Hook
* Pushing to Remote


<a name="one"></a>
###Step One: Create the humans.txt File

The first thing you need to do to begin this process is create a humans.txt file. You can create your own using their template from their [website](http://humanstxt.org/Standard.html). 

Once you have your file created, using your Finder tool(MacOS) you can place that file in the root directory of the theme folder that your Wordpress site on the VPS is using. Also, using your editor or the terminal, insert this line into your `header.php` file in the `head` tag: 

```shell
 <link rel="author" href="http://138.197.117.60/humans.txt" />
```

Then you can insert a link to the txt file somewhere in your document (this tutorial places it in the `footer.php` file)

```shell
<link ref="author" href="http://138.197.117.60/humans.txt" />
``` 
After that you are ready to begin working on the rest of the steps. 

<a name="two"></a>
###Step Two: Unit Testing

The next step we can take is implementing unit testing that will be triggered on a `pre-commit` hook. 

To do this, you will need to initialize your project with node. This is done through the command: 

```shell
npm init
```
Answer the prompts to your own preference, however the entry point is not relevant since we will not actually be running `npm start` on this application. 

After the prompts have finished, you will need to install a couple of packages. To complete the unit test you will need to install `mocha`, and for the `pre-commit` we are going to be using a package called `pre-commit` (fitting, right?). To install these packages into your `package.json`, run: 

```shell
npm install mocha --save-dev
npm install pre-commit --save-sev
```

After those packages install, your `package.json` should have a section for `dev-dependancies` and it should list `mocha` and `pre-commit` within it. 

With that complete, you now need to create a folder titled `test` in the base root directory of your project, with a file titled `test.js` within it. 

Inside that `test.js` file, insert this code: 

```shell
var assert = require('assert');
describe('Array', function() {
  describe('#indexOf()', function() {
    it('Running unit test...', function(done) {
      if (1==1) {
        console.log("test passed!");
        done();
      } else {
        console.log("Unit test failed! Commit aborted.");
      }
    });
  });
});
```

This is the code that Mocha needs to run it's test. As it stands, this test will always pass which is what we want for the sake of this tutorial. However, you can change the values to cause a fail if you want to see what happens then. 

TO test if it passed, you can run this line in your terminal: 

```shell
 ./node_modules/mocha/bin/mocha
```

Next step is the Git hook. Hooks are located in the hidden `.git` folder of any git repository. To access them, you simply navigate there from your root directory through terminal: 

```shell
cd .git/hooks
```

One already exists for `pre-commit`, but because it has a `.sample` extension, it does not run. To make it so this hook fires, simply run:

```shell
cp pre-commit.sample pre-commit
```

This will create a new file called `pre-commit` without the extension that will contain all the code from the pre-generated one. 

Now because of the `pre-commit` npm package we installed, this is all we have to do here. That package will know when a commit happens and fire off that hook and run the unit test for us, no problem!

<a name="three"></a>
###Step Three: Post-Merge Hook

The last hook we need to set up on the local side is the post-merge hook. This needs to fire after a merge happens on the release branch and it will then push our files to our remote repository, at which point the post-receive hook we set up on that end will fire and push our files into our live folder. 

Before that though, we need to run the line: 

```shell
git remote add Production ssh://[username]@[ip]:/var/repos/wp.git
```

This will create the connecion to our remote repository that will allow for us to push files there. 

Create the post-merge hook:

```shell
touch post-merge
```
Use `nano` to open that new file so we can edit it, and place this code there: 

```shell
#!/bin/bash

one=$(git merge-base HEAD^1 release)
two=$(git rev-parse --verify HEAD^1)

if [[ $one == $two ]];
then
        echo "Pushing to Production master..."
        git push Production master
        exit
else
        echo "Did not push to Production master. Make sure you are on release branch"
        exit
fi

```

This will make sure that you are on the release branch when you merge, and then fire the appropriate commands accordingly. The `push` command is pushing our files into the metadata of the `Production` remote repository which will then be transferred to the live folder through the `post-receive` hook on the remote end.

After that hook is made, you're all set! Add your humans.txt file to your feature branch files, `checkout` your release branch, `merge` your feature branch into your release branch, and you should see your humans.txt file appear in the `/var/www/html` folder on your server!

###Resources

