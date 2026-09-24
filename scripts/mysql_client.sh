#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p "$dir_user"

set -x
yum update -y

install_mysql_client() {
  cd "$dir_user" || exit
  dnf install mariadb105
}
install_mysql_client
