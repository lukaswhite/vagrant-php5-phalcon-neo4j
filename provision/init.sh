#!/bin/bash
# Using Precise64 Ubuntu

sudo apt-get update
#
# For PHP 5.5
#
sudo apt-get install -y python-software-properties
sudo add-apt-repository ppa:ondrej/php5
sudo apt-get update

#
# MySQL with root:<no password>
#
export DEBIAN_FRONTEND=noninteractive
apt-get -q -y install mysql-server

#
# PHP
#
sudo apt-get install -y php5 php5-dev apache2 libapache2-mod-php5 php5-mysql php5-curl php5-mcrypt libpcre3-dev

#
# Redis
#
sudo apt-get install -y redis-server

#
# MongoDB
#
sudo apt-get install mongodb-clients mongodb-server

#
# Utilities
#
sudo apt-get install -y make curl htop git-core vim

#
# Redis Configuration
# Allow us to Remote from Vagrant with Port
#
sudo cp /etc/redis/redis.conf /etc/redis/redis.bkup.conf
sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
sudo /etc/init.d/redis-server restart

#
# MySQL Configuration
# Allow us to Remote from Vagrant with Port
#
sudo cp /etc/mysql/my.cnf /etc/mysql/my.bkup.cnf
# Note: Since the MySQL bind-address has a tab cahracter I comment out the end line
sudo sed -i 's/bind-address/bind-address = 0.0.0.0#/' /etc/mysql/my.cnf

#
# Grant All Priveleges to ROOT for remote access
#
mysql -u root -Bse "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"
sudo service mysql restart



#
# Composer for PHP
#
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

#
# NPM
# 
sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update
sudo apt-get install -y nodejs > /dev/null
sudo npm install npm -g

#
# Bower
# 
sudo npm install -g bower

# 
# Java 7
# 
cd /usr/local
wget -nv -O jre-7u45-linux-x64.gz http://javadl.sun.com/webapps/download/AutoDL?BundleId=81812
tar -xf jre-7u45-linux-x64.gz
rm jre-7u45-linux-x64.gz
ln -s /usr/local/jre1.7.0_45/bin/java /usr/bin/java

# 
# Neo4j
#
cd /etc
wget -nv http://dist.neo4j.org/neo4j-community-2.0.0-M06-unix.tar.gz
tar -xf neo4j-community-2.0.0-M06-unix.tar.gz
rm neo4j-community-2.0.0-M06-unix.tar.gz
ln -s /etc/neo4j-community-2.0.0-M06/bin/neo4j /usr/bin/neo4j

sed -i 's/#org\.neo4j\.server\.webserver\.address=0\.0\.0\.0/org.neo4j.server.webserver.address=0.0.0.0/' /etc/neo4j-community-2.0.0-M06/conf/neo4j-server.properties

neo4j start

sudo su -
printf '%s\t%s\t%s\t%s\n%s\t%s\t%s\t%s\n' 'neo4j' 'soft' 'nofile' '40000' 'neo4j' 'hard' 'nofile' '40000' >> /etc/security/limits.conf
printf '%s\t%s\t%s\n' 'session' 'required' 'pam_limits.so' >> /etc/pam.d/su

#
# Apache VHost
#
cd ~
echo '<VirtualHost *:80>
        DocumentRoot /vagrant/www
</VirtualHost>

<Directory "/vagrant/www">
        Options Indexes Followsymlinks
        AllowOverride All
        Require all granted
</Directory>' > vagrant.conf

sudo mv vagrant.conf /etc/apache2/sites-available
sudo a2enmod rewrite

#
# Install PhalconPHP
# Enable it
#
cd ~
git clone --depth=1 https://github.com/phalcon/cphalcon.git
cd cphalcon/build
sudo ./install

echo "extension=phalcon.so" > phalcon.ini
sudo mv phalcon.ini /etc/php5/mods-available
sudo php5enmod phalcon
sudo php5enmod curl
sudo php5enmod mcrypt

#
# Update PHP Error Reporting
#
sudo sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php5/apache2/php.ini
sudo sed -i 's/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT/error_reporting = E_ALL/' /etc/php5/apache2/php.ini
sudo sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini 
# Append session save location to /tmp to prevent errors in an odd situation..
sudo sed -i '/\[Session\]/a session.save_path = "/tmp"' /etc/php5/apache2/php.ini


#
# Install PhalconPHP DevTools
#
cd ~
echo '{"require": {"phalcon/devtools": "dev-master"}}' > composer.json
composer install
rm composer.json

sudo mkdir /opt/phalcon-tools
sudo mv ~/vendor/phalcon/devtools/* /opt/phalcon-tools
sudo ln -s /opt/phalcon-tools/phalcon.php /usr/bin/phalcon
sudo rm -rf ~/vendor

#
# Reload apache
#
sudo a2ensite vagrant
sudo a2dissite 000-default
sudo service apache2 reload
sudo service apache2 restart
sudo service mongodb restart

echo -e "----------------------------------------"
echo -e "To create a Phalcon Project:\n"
echo -e "----------------------------------------"
echo -e "$ cd /vagrant/www"
echo -e "$ phalcon project projectname\n"
echo -e
echo -e "Then follow the README.md to copy/paste the VirtualHost!\n"

echo -e "----------------------------------------"
echo -e "Default Site: http://192.168.5.0"
echo -e "----------------------------------------"
