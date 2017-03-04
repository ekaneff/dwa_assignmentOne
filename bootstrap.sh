#!/usr/bin/env bash

apt-get update

if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi

echo "Installing Git"
apt-get install git -y > /dev/null
    
echo "Installing Nginx"
apt-get install nginx -y > /dev/null

echo "Installing PHP"
apt-get install php-fpm php-mysql -y > /dev/null

echo "Installing debconf-utils"
apt-get install debconf-utils -y > /dev/null

echo "Setting root password"
debconf-set-selections <<< "mariadb-server mysql-server/root_password password 1234"
    
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password 1234"

echo "Installing MariaDb"
apt-get install mariadb-server -y > /dev/null

echo "Creating Database"
mysql -e "CREATE DATABASE localwordpress"
mysql -e "GRANT ALL PRIVILEGES ON localwordpress.* TO root@localhost IDENTIFIED BY '1234'"

echo "Configuring Nginx"
cp /var/www/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
    
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/
    
rm -rf /etc/nginx/sites-available/default

rm -rf app/cache/*
rm -rf app/logs/*
    
systemctl reload nginx > /dev/null








