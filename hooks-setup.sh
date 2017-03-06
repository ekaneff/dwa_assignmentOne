#!/bin/sh

echo "Making wp.git Directory"
mkdir -p /var/repos/wp.git

echo "Changing Directory to wp.git"
cd /var/repos/wp.git

echo "Initializing bare repository"
git init --bare

echo "Creating post-receive hook"
cd hooks
touch post-receive
chmod +x post-receive

echo "Adding logic to post-receive"
file="post-receive"
echo "#!/bin/sh" > $file
echo "GIT_WORK_TREE=/var/www/html git checkout -f" >> $file
cd /