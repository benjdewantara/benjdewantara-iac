#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user
git_uri_defectdojo='${git_uri_defectdojo}'

set -x
yum update -y
yum install -y git

defectdojo_install() {
  cd $dir_user || exit
  git clone $git_uri_defectdojo
  chown -R ec2-user: $dir_user
}
defectdojo_install
