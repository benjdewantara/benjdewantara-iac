#!/usr/bin/env bash

echo "This is the start of ec2-pub-postgres\user_data.sh"

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

output_states_to_file() {
  timestamp_txt=$(date --rfc-3339=s | sed -E -e 's/\W/./g')
  find /usr/ /etc/ -type f >"$dir_user/$timestamp_txt.usr-etc-content"
  systemctl list-units >"$dir_user/$timestamp_txt.systemctl-list-units"
}

# initial state
output_states_to_file

yum install -y postgresql18.x86_64
output_states_to_file

yum install -y postgresql18-server.x86_64
output_states_to_file

postgresql-setup --initdb
systemctl enable postgresql.service
systemctl start postgresql.service

# postgresql running
output_states_to_file

cd "$dir_user" || exit
LATEST=$(curl -i https://github.com/zitadel/zitadel/releases/latest | grep location: | cut -d '/' -f 8 | tr -d '\r'); ARCH=$(uname -m); case $ARCH in armv5*) ARCH="armv5";; armv6*) ARCH="armv6";; armv7*) ARCH="arm";; aarch64) ARCH="arm64";; x86) ARCH="386";; x86_64) ARCH="amd64";;  i686) ARCH="386";; i386) ARCH="386";; esac; wget -c https://github.com/zitadel/zitadel/releases/download/$LATEST/zitadel-linux-$ARCH.tar.gz -O - | tar -xz && sudo mv zitadel-linux-$ARCH/zitadel /usr/local/bin

# download zitadel
output_states_to_file

chown -R ec2-user: $dir_user

echo "This is the end of ec2-pub-postgres\user_data.sh"
