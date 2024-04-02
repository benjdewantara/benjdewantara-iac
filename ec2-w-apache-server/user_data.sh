#!/bin/bash

set -x
sudo -s

yum update -y

yum install -y httpd
[[ $(systemctl is-enabled httpd) != "enabled" ]] && systemctl start httpd && systemctl enable httpd

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

read -r -d '' insertThis <<EOM
<FilesMatch ".(ico|pdf|flv|jpg|jpeg|png|gif|js|css|swf)$">
 Header set Cache-Control "max-age=63072000, public"
</FilesMatch>

Listen 80
<VirtualHost *:80>
    DocumentRoot "/var/www/html"
    ServerName "${domainNameThis}"
    ServerAlias "www.${domainNameThis}"
</VirtualHost>
EOM

echo "$insertThis" >/etc/httpd/conf/insertContent.txt
sed -e '/Listen 80/ {' -e "r /etc/httpd/conf/insertContent.txt" -e 'd' -e '}' -i /etc/httpd/conf/httpd.conf

read -r -d '' insertThis <<EOM
<html>
  <body>
    <p>Hello world at $(date --iso-8601='ns' | sed -e 's/,/./')</p>
    <img src="random.jpg">
  </body>
</html>
EOM

echo "$insertThis" >/var/www/html/index.html

mkdir -r "/var/www/img"
curl --request GET -sL \
     --url 'https://picsum.photos/200/300?random=2'\
     --output '/var/www/html/random.jpg'

# unalias rm1
# /bin/rm /etc/httpd/conf/insertContent.txt

yum install -y mod_ssl
cd /etc/pki/tls/certs
./make-dummy-cert localhost.crt

/bin/cp localhost.crt localhost.key

sed -n '/-----BEGIN PRIVATE KEY-----/, /-----END PRIVATE KEY-----/p' localhost.crt >/etc/pki/tls/private/localhost.key

systemctl restart httpd

yum update -y
amazon-linux-extras install epel -y
yum install -y certbot python2-certbot-apache

#certbot run --apache --non-interactive --agree-tos --domains "${domainNameThis},www.${domainNameThis}" -m ${email_certbot}
