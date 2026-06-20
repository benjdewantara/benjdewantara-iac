#!/usr/bin/env bash

echo "This is the start of ec2-pub-postgres\user_data.sh"

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

output_states_to_file() {
  find /usr/ /etc/ -type f >"$dir_user/usr-etc-content.$timestamp_txt"
  systemctl list-units >"$dir_user/systemctl-list-units.$timestamp_txt"
}

timestamp_txt=$(date --rfc-3339=s | sed -E -e 's/\W/./g')
output_states_to_file

yum install -y postgresql18.x86_64
output_states_to_file

yum install -y postgresql18-server.x86_64
output_states_to_file

chown -R ec2-user: $dir_user

echo "This is the end of ec2-pub-postgres\user_data.sh"
