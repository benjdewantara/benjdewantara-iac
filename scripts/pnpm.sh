#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

install_pnpm() {
  npm install -g pnpm@latest-11
}
install_pnpm
