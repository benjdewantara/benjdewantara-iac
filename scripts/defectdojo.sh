#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

defectdojo() {
  npm install -g pnpm@latest-11
}
defectdojo
