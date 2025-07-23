#!/usr/bin/env sh

echo "This is the start of ec2-lambda-al2023-python3-12/user_data_template.sh"
sudo -s
set -x

cd

HOME="/home/ec2-user"
touch "$HOME/timestamp-before-isntalling-python-3-12"
yum update -y
# yum install -y python3.12
yum install -y pip
