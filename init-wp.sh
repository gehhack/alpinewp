#!/bin/ash

#Clean and update apk
rm -rf /var/cache/apk/* && rm -rf /tmp/*
apk update
apk add alpine-sdk

#Copy motd
cp -f ./motd /etc/motd

#ACF
setup-acf
rm -f /etc/mini_httpd/mini_httpd.conf
cp mini_httpd.conf /etc/mini_httpd/mini_httpd.conf
mv /var/www/localhost/htdocs /var/www/localhost/acf
/etc/init.d/mini_httpd restart

#Database
apk add mariadb mariadb-client
/etc/init.d/mariadb setup
sleep 1
rc-update add mariadb
sleep 1
/etc/init.d/mariadb start
sleep 1


#Configure SSHD
setup-sshd
rc-update add sshd
/etc/init.d/sshd start

#Repositories
#wget -O /etc/apk/keys/php-alpine.rsa.pub http://php.codecasts.rocks/php-alpine.rsa.pub
#echo "@php http://php.codecasts.rocks/v3.6/php-7.1" >> /etc/apk/repositories

#Install packages
#apk add --update php7-redis@php
apk add pwgen
apk add apache2
apk add php7
apk add php7 
apk add php7-common 
apk add php7-fpm 
apk add php7-cgi 
apk add php7-apache2 
apk add php7-curl 
apk add php7-gd 
apk add php7-mbstring 
apk add php7-mcrypt 
apk add php7-pdo 
apk add php7-mcrypt 
apk add php7-mysqli 
#apk add php7-mysql
apk add git
apk add zlib-dev
apk add zlib
apk add php7-zlib
apk add php7-session
sleep 2

#Git Wordpress
rm -f /var/www/localhost/htdocs/index.html
git clone https://github.com/WordPress/WordPress.git /var/www/localhost/htdocs/

#Git PhpMyadmin
git clone https://github.com/phpmyadmin/phpmyadmin.git /var/www/localhost/htdocs/phpmyadmin

#Chown & chmod www
chown -R apache:apache /var/www/localhost/htdocs
chmod -R 700 /var/www/localhost/htdocs/phpmyadmin/setup

#Apache2 start & boot
rc-update add apache2
/etc/init.d/apache2 start
sleep 2

#Configuration database
USER=`pwgen -A 8 1`
PASS=`pwgen -s 32 1`
ROOTPASS=`pwgen -s 32 1`
DIR='/var/www/localhost/htdocs'

mysqladmin -u root password $ROOTPASS
#mysqladmin -u root -h $HOSTNAME password $ROOTPASS

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
echo "rootPWD    :   $ROOTPASS" >> "/root/access.txt"
echo "UserDB     :   $USER" >> "/root/access.txt"
echo "PasswordDB :   $PASS" >> "/root/access.txt"

#Refresh Apache2
/etc/init.d/apache2 reload

exit
