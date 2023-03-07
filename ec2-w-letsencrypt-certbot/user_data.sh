#!/bin/bash

set -x
sudo -s

yum update -y

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SSL-on-amazon-linux-2.html#letsencrypt
wget -r --no-parent -A 'epel-release-*.rpm' https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/
rpm -Uvh dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-*.rpm
yum-config-manager --enable epel*
yum repolist all

<<instruction
Edit the main Apache configuration file, /etc/httpd/conf/httpd.conf. Locate the "Listen 80" directive and add the following lines after it, replacing the example domain names with the actual Common Name and Subject Alternative Name (SAN).

<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName "example.com"
    ServerAlias "www.example.com"
</VirtualHost>
instruction

sudo read -r -d '' insertThis << EOM
Listen 80
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName "letsencrypt.example.id"
    ServerAlias "www.letsencrypt.example.id"
</VirtualHost>
EOM

sudo echo "" > /etc/httpd/conf/insertContent.txt
sudo echo "$insertThis" > /etc/httpd/conf/insertContent.txt

# unalias cp
sudo /bin/cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak

sudo sed -e '/Listen 80/ {' -e "r /etc/httpd/conf/insertContent.txt" -e 'd' -e '}' -i /etc/httpd/conf/httpd.conf.bak

# unalias rm
sudo /bin/rm /etc/httpd/conf/insertContent.txt

systemctl restart httpd

yum update -y
amazon-linux-extras install epel -y
yum install -y certbot python2-certbot-apache
# certbot
