#!/usr/bin/env sh

echo "This is the start of ec2-nodejs-hello-world-server/user_data_template.sh"

HOME="/home/ec2-user"

set -x

cd $HOME || exit

yum update -y

