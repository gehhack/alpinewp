#!/bin/ash

#Copy motd

cp -f ./motd /etc/motd

#Configure SSHD
setup-sshd
rc-update add sshd
/etc/init.d/sshd start

#Repositories
wget -O /etc/apk/keys/php-alpine.rsa.pub http://php.codecasts.rocks/php-alpine.rsa.pub
echo "@php http://php.codecasts.rocks/v3.6/php-7.1" >> /etc/apk/repositories

#Install packages
apk add --update php7-redis@php
apk add pwgen
apk add apache2
apk add php7
apk add php7 php7-common php7-fpm php7-cgi php7-apache2 php7-curl php7-gd php7-mbstring php7-mcrypt php7-pdo php7-mcrypt php7-mysqli php7-mysql
apk add mysql mysql-client
apk add git

#Git Wordpress
git clone https://github.com/WordPress/WordPress.git /var/www/localhost/htdocs/

#Apache2 start & boot
rc-update add apache2
/etc/init.d/apache2 start
rm -f /var/www/localhost/htdocs/index.html

#Database
rc-update add mariadb
/etc/init.d/mariadb start

USER=`pwgen -A 8 1`
PASS=`pwgen -s 32 1`
ROOTPASS=`pwgen -s 32 1`
DIR='/var/www/localhost/htdocs'

mysqladmin -u root password $ROOTPASS
mysqladmin -u root -h $HOSTNAME password $ROOTPASS

mysql -uroot -p${ROOTPASS} <<MYSQL_SCRIPT
CREATE DATABASE $USER;
CREATE USER '$USER'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USER.* TO '$USER'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

#Configuration Wordpress
#Rename the default config file
cp -f $DIR/wp-config-sample.php $DIR/wp-config.php

#Substitute the default database values
sed -i "/DB_NAME/s/'[^']*'/'${USER}'/2" $DIR/wp-config.php
sed -i "/DB_USER/s/'[^']*'/'${USER}'/2" $DIR/wp-config.php
sed -i "/DB_PASSWORD/s/'[^']*'/'${PASS}'/2" $DIR/wp-config.php

#Statut des services au demarrage
rc-status

#Infos MDP et USER
echo "Informations in /root/access.txt"
echo "User" >> "/root/access.txt"
echo "rootPWD :   $ROOTPASS" >> "/root/access.txt"
echo "User DB :   $USER" >> "/root/access.txt"
echo "Password:   $PASS" >> "/root/access.txt"

exit
