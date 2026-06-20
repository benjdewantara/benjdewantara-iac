#!/usr/bin/env bash

echo "This is the start of ec2-pub-postgres\user_data.sh"

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

timestamp_txt=$(date --rfc-3339=s | sed -E -e 's/\W/./g')
find /usr/ /etc/ -type f >"$dir_user/usr-etc-content.$timestamp_txt"
systemctl list-units >"$dir_user/systemctl-list-units.$timestamp_txt"

chown -R ec2-user: $dir_user

echo "This is the end of ec2-pub-postgres\user_data.sh"
