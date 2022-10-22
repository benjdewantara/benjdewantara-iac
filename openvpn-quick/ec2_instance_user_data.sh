#!/bin/bash
set -x

sudo -s

yum update -y
yum install -y nc tc

# Visited this tutorial re: installing OpenVPN server https://tecadmin.net/install-openvpn-centos-8/
sysctl -w net.ipv4.ip_forward=1
amazon-linux-extras install -y epel
yum update -y

yum install -y easy-rsa openvpn firewalld
yum update -y

mkdir -p /etc/easy-rsa
cd /etc/easy-rsa

cat <<EOF | tee /etc/easy-rsa/vars
#!/bin/sh

# consult https://github.com/OpenVPN/easy-rsa.git, file vars.example

set_var EASYRSA                 "$PWD"
set_var EASYRSA_OPENSSL         "openssl"
#set_var EASYRSA_OPENSSL         "C:/Program Files/OpenSSL-Win32/bin/openssl.exe"
set_var EASYRSA_PKI             "$PWD/pki"
#set_var EASYRSA_TEMP_DIR        "$EASYRSA_PKI"

#set_var EASYRSA_DN              "cn_only"
set_var EASYRSA_DN              "org"

set_var EASYRSA_REQ_COUNTRY     "ID"
set_var EASYRSA_REQ_PROVINCE    "West Java"
set_var EASYRSA_REQ_CITY        "Bandung"
set_var EASYRSA_REQ_ORG         "Benj Certificate Co"
set_var EASYRSA_REQ_EMAIL       "me@test.id"
set_var EASYRSA_REQ_OU          "Benj Organizational Unit"

set_var EASYRSA_KEY_SIZE        2048

set_var EASYRSA_ALGO            rsa
#set_var EASYRSA_ALGO            ec
#set_var EASYRSA_ALGO            ed
#set_var EASYRSA_CURVE           secp384r1

set_var EASYRSA_CA_EXPIRE       30
set_var EASYRSA_CERT_EXPIRE     30
set_var EASYRSA_CRL_DAYS        1

set_var EASYRSA_RAND_SN         "no"
#set_var EASYRSA_RAND_SN         "yes"

set_var EASYRSA_NS_SUPPORT      "no"
#set_var EASYRSA_NS_SUPPORT      "yes"
#set_var EASYRSA_NS_COMMENT      "Easy-RSA Generated Certificate"

#set_var EASYRSA_TEMP_FILE       "$EASYRSA_PKI/extensions.temp"

#set_var EASYRSA_EXT_DIR         "$EASYRSA/x509-types"

#set_var EASYRSA_KDC_REALM       "CHANGEME.EXAMPLE.COM"

set_var EASYRSA_SSL_CONF        "$EASYRSA_PKI/openssl-easyrsa.cnf"

#set_var EASYRSA_REQ_CN          "ChangeMe"

#set_var EASYRSA_DIGEST          "sha256"

#set_var EASYRSA_BATCH           ""


# consult https://github.com/OpenVPN/easy-rsa.git, do not uncomment this
#set_var EASYRSA_CERT_RENEW      30
#set_var EASYRSA_FIX_OFFSET      183

EOF

cp -f -r /usr/share/easy-rsa/3/* -t /etc/easy-rsa/
cd /etc/easy-rsa
./easyrsa init-pki

# from this point on, this needs to be done manually
# refer to https://www.howtoforge.com/tutorial/how-to-install-openvpn-server-and-client-with-easy-rsa-3-on-centos-8/
# this cannot be done automatically by EC2 instance's user data



# sudo -s # begin `-s`
export EASYRSA_BATCH=1

./easyrsa build-ca nopass

./easyrsa gen-req benj-openvpn-server nopass
./easyrsa sign-req server benj-openvpn-server
openssl verify -CAfile pki/ca.crt pki/issued/benj-openvpn-server.crt

./easyrsa gen-req client00 nopass
./easyrsa sign-req client client00
openssl verify -CAfile pki/ca.crt pki/issued/client00.crt

./easyrsa gen-req client01 nopass
./easyrsa sign-req client client01
openssl verify -CAfile pki/ca.crt pki/issued/client01.crt

./easyrsa gen-req client02 nopass
./easyrsa sign-req client client02
openssl verify -CAfile pki/ca.crt pki/issued/client02.crt

./easyrsa gen-req client03 nopass
./easyrsa sign-req client client03
openssl verify -CAfile pki/ca.crt pki/issued/client03.crt

./easyrsa gen-dh

# test revoking
./easyrsa revoke client00
./easyrsa gen-crl

# exit # exit `-s`

# move the certificates to OpenVPN directory

cp /etc/easy-rsa/pki/ca.crt /etc/openvpn/server/
cp /etc/easy-rsa/pki/issued/benj-openvpn-server.crt /etc/openvpn/server/
cp /etc/easy-rsa/pki/private/benj-openvpn-server.key /etc/openvpn/server/

cp /etc/easy-rsa/pki/ca.crt /etc/openvpn/client/

cp /etc/easy-rsa/pki/issued/client01.crt /etc/openvpn/client/
cp /etc/easy-rsa/pki/private/client01.key /etc/openvpn/client/

cp /etc/easy-rsa/pki/issued/client02.crt /etc/openvpn/client/
cp /etc/easy-rsa/pki/private/client02.key /etc/openvpn/client/

cp /etc/easy-rsa/pki/issued/client03.crt /etc/openvpn/client/
cp /etc/easy-rsa/pki/private/client03.key /etc/openvpn/client/

cp /etc/easy-rsa/pki/dh.pem /etc/openvpn/server/
cp /etc/easy-rsa/pki/crl.pem /etc/openvpn/server/

<<manuallyDoThis
manuallyDoThis

cat <<EOF | tee /etc/openvpn/server/server.conf
# OpenVPN Port, Protocol, and the Tun
port 1194
proto udp
dev tun

# OpenVPN Server Certificate - CA, server key and certificate
ca /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/benj-openvpn-server.crt
key /etc/openvpn/server/benj-openvpn-server.key

#DH and CRL key
dh /etc/openvpn/server/dh.pem
# crl-verify /etc/openvpn/server/crl.pem

# Network Configuration - Internal network
# Redirect all Connection through OpenVPN Server
server 10.5.0.0 255.255.255.0
push "redirect-gateway def1"

# Using the DNS from https://dns.watch
push "dhcp-option DNS 84.200.69.80"
push "dhcp-option DNS 84.200.70.40"

#Enable multiple clients to connect with the same certificate key
duplicate-cn

# TLS Security
cipher AES-256-CBC
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256
auth SHA512
auth-nocache

# Other Configuration
keepalive 20 60
persist-key
persist-tun
compress lz4
daemon
user nobody
group nobody

# OpenVPN Log
log-append /var/log/openvpn.log
verb 3
EOF


mkdir -p /etc/openvpn/buildovpnfile/
cd /etc/openvpn/buildovpnfile/

cat <<EOF | tee /etc/openvpn/buildovpnfile/client.ovpn.template
client
dev tun
proto udp

remote %IPPUBLIC% 1194

#ca ca.crt
#cert client02.crt
#key client02.key

cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256

resolv-retry infinite
compress lz4
nobind
persist-key
persist-tun
mute-replay-warnings
verb 3

<ca>
%CA%
</ca>

<cert>
%CERT%
</cert>

<key>
%KEY%
</key>
EOF

# sudo -s # begin `-s`

clientname="client01"
cp client.ovpn.template $clientname.ovpn
cd /etc/openvpn/buildovpnfile/

curl http://169.254.169.254/latest/meta-data/public-ipv4 > /etc/openvpn/buildovpnfile/$clientname-ipPub.txt
cat /etc/openvpn/server/ca.crt > /etc/openvpn/buildovpnfile/$clientname-caCrt.txt
cat /etc/openvpn/client/client01.crt | sed -r -e '/Certificate:/d' | sed -r -e '/^ +.+$/d' | sed -r -e '/^\s*$/d' > /etc/openvpn/buildovpnfile/$clientname-clientCrt.txt
cat /etc/openvpn/client/client01.key > /etc/openvpn/buildovpnfile/$clientname-clientKey.txt

sed -e "s/%IPPUBLIC%/`cat /etc/openvpn/buildovpnfile/$clientname-ipPub.txt`/1" -i $clientname.ovpn
sed -e '/%CA%/ {' -e "r /etc/openvpn/buildovpnfile/$clientname-caCrt.txt" -e 'd' -e '}' -i $clientname.ovpn
sed -e '/%CERT%/ {' -e "r /etc/openvpn/buildovpnfile/$clientname-clientCrt.txt" -e 'd' -e '}' -i $clientname.ovpn
sed -e '/%KEY%/ {' -e "r /etc/openvpn/buildovpnfile/$clientname-clientKey.txt" -e 'd' -e '}' -i $clientname.ovpn

# exit # exit `-s`

<<manuallyDoThis

cd /etc/openvpn/buildovpnfile/

# sudo -s
cat
sed -e '/REPLACETHIS/ {' -e 'r tempt.txt' -e 'd' -e '}'

curl http://169.254.169.254/latest/meta-data/public-ipv4 > /etc/openvpn/buildovpnfile/ipPub.txt
cat /etc/openvpn/server/ca.crt > /etc/openvpn/buildovpnfile/caCrt.txt
cat /etc/openvpn/client/client01.crt | sed -r -e '/Certificate:/d' | sed -r -e '/^ +.+$/d' > /etc/openvpn/buildovpnfile/clientCrt.txt
cat /etc/openvpn/client/client01.key > /etc/openvpn/buildovpnfile/clientKey.txt

ipPub=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
caCrt=`cat /etc/openvpn/server/ca.crt`
clientCrt=`cat /etc/openvpn/client/client01.crt | sed -r -e '/Certificate:/d' | sed -r -e '/^ +.+$/d'`
clientKey=`cat /etc/openvpn/client/client01.key`

%CA%
%CERT%
%KEY%

cat /etc/openvpn/client/client01.ovpn | sed -r -e "s/%IPPUBLIC%/$ipPub/g"
cat /etc/openvpn/client/client01.ovpn | sed -r -e "s/%CA%/$caCrt/g"
cat /etc/openvpn/client/client01.ovpn | sed -r -e "s/%CERT%/$clienCrt/g"
cat /etc/openvpn/client/client01.ovpn | sed -r -e "s/%KEY%/$clientKey/g"


manuallyDoThis


systemctl start firewalld
systemctl enable firewalld

firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-service=openvpn

firewall-cmd --permanent --zone=trusted --add-interface=tun0

firewall-cmd --permanent --add-masquerade

SERVERIP=$(ip route get 1.1.1.1 | awk 'NR==1 {print $(NF-2)}')
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.5.0.0/24 -o $SERVERIP -j MASQUERADE

firewall-cmd --reload

systemctl start openvpn-server@server
systemctl enable openvpn-server@server

<<manuallyDoThis
manuallyDoThis


