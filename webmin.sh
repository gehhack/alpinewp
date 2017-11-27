#!/bin/ash

apk update
apk add pwgen
apk add sudo
apk add tar

WEBMIN_USERNAME=`pwgen -A 8 1`
WEBMIN_PASSWORD=`pwgen -s 32 1`

WEBMIN_PORT=10238
WEBMIN_USERNAME=admin
WEBMIN_PASSWORD=webmin

set -e

apk add curl perl
#wget https://prdownloads.sourceforge.net/webadmin/webmin-1.860.tar.gz

tar zxf webmin-1.860-minimal.tar.gz
tar zxf webmin-1.860-minimal.tar.gz -C /var/lib/
mv /var/lib/webmin-1.860 /var/lib/webmin
#rm -rf webmin-1.860-minimal.tar.gz
cd /var/lib/webmin
mkdir -p /etc/rc.d/init.d/
cat <<EOF | ./setup.sh
/etc/webmin
/var/log/webmin
/usr/bin/perl
101
4
${WEBMIN_PORT}
${WEBMIN_USERNAME}
${WEBMIN_PASSWORD}
${WEBMIN_PASSWORD}
y
EOF
cat <<EOF | tee /etc/init.d/webmin
#!/sbin/openrc-run
WEBMIN=/etc/rc.d/init.d/webmin
start() { \${WEBMIN} start; }
stop() { \${WEBMIN} start; }
EOF
chmod a+x /etc/init.d/webmin

rc-update add webmin
rc-service webmin start

echo "Informations in /root/access.txt"
echo "User" >> "/root/access.txt"
echo "Port Webmin : $WEBMIN_PORT" >> "/root/access.txt"
echo "User Webmin : $WEBMIN_USERNAME" >> "/root/access.txt"
echo "MDP Webmin :$WEBMIN_PASSWORD" >> "/root/access.txt"
