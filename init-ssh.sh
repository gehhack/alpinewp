#!/bin/ash

#Clean and update apk
rm -rf /var/cache/apk/* && rm -rf /tmp/*
apk update

#Install SDK
apk add alpine-sdk

#Copy motd
cp -f ./motd /etc/motd

#Configure SSHD
setup-sshd
rc-update add sshd
/etc/init.d/sshd start
echo "PermitRootLogin Yes" >> "/etc/ssh/sshd_config"

#Statut des services au demarrage
rc-status

exit
