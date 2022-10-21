#!/bin/bash
set -x

sudo yum update -y
sudo yum install -y nc tc

# Visited this tutorial re: installing OpenVPN server https://tecadmin.net/install-openvpn-centos-8/
sudo sysctl -w net.ipv4.ip_forward=1
sudo amazon-linux-extras install -y epel
sudo yum update -y

sudo yum install -y easy-rsa openvpn firewalld
sudo yum update -y

sudo mkdir -p /etc/easy-rsa
cd /etc/easy-rsa

cat <<EOF | sudo tee /etc/easy-rsa/vars
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

sudo cp -r /usr/share/easy-rsa/3/* -t /etc/easy-rsa/
cd /etc/easy-rsa
sudo ./easyrsa init-pki

# from this point on, this needs to be done manually
# refer to https://www.howtoforge.com/tutorial/how-to-install-openvpn-server-and-client-with-easy-rsa-3-on-centos-8/
# this cannot be done automatically by EC2 instance's user data

<<manuallyDoThis

sudo ./easyrsa build-ca

sudo -s
./easyrsa gen-req benj-openvpn-server nopass
./easyrsa sign-req server benj-openvpn-server
openssl verify -CAfile pki/ca.crt pki/issued/benj-openvpn-server.crt

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
./easyrsa revoke client01
./easyrsa gen-crl

exit

# move the certificates to OpenVPN directory

sudo cp /etc/easy-rsa/pki/ca.crt /etc/openvpn/server/
sudo cp /etc/easy-rsa/pki/issued/benj-openvpn-server.crt /etc/openvpn/server/
sudo cp /etc/easy-rsa/pki/private/benj-openvpn-server.key /etc/openvpn/server/

sudo cp /etc/easy-rsa/pki/ca.crt /etc/openvpn/client/

sudo cp /etc/easy-rsa/pki/issued/client01.crt /etc/openvpn/client/
sudo cp /etc/easy-rsa/pki/private/client01.key /etc/openvpn/client/

sudo cp /etc/easy-rsa/pki/issued/client02.crt /etc/openvpn/client/
sudo cp /etc/easy-rsa/pki/private/client02.key /etc/openvpn/client/

sudo cp /etc/easy-rsa/pki/issued/client03.crt /etc/openvpn/client/
sudo cp /etc/easy-rsa/pki/private/client03.key /etc/openvpn/client/

sudo cp /etc/easy-rsa/pki/dh.pem /etc/openvpn/server/
sudo cp /etc/easy-rsa/pki/crl.pem /etc/openvpn/server/

manuallyDoThis

cat <<EOF | sudo tee /etc/openvpn/server/server.conf
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

<<manuallyDoThis

sudo systemctl start firewalld
sudo systemctl enable firewalld

firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-service=openvpn

firewall-cmd --permanent --zone=trusted --add-interface=tun0

firewall-cmd --permanent --add-masquerade

SERVERIP=$(ip route get 1.1.1.1 | awk 'NR==1 {print $(NF-2)}')
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s 10.5.0.0/24 -o $SERVERIP -j MASQUERADE

firewall-cmd --reload

sudo systemctl start openvpn-server@server
sudo systemctl enable openvpn-server@server

manuallyDoThis


