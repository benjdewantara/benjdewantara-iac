#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user
git_uri_defectdojo='${git_uri_defectdojo}'

set -x
yum update -y
yum install -y git

defectdojo_install() {
  cd "$dir_user" || exit
  local marker=$(mktemp)
  set +x
  git clone $git_uri_defectdojo
  set -x
  chown -R ec2-user: $dir_user

  local dir_git=$(find . -type d -newer $marker | sed '2!d')
  cd "$dir_git" || exit
  docker compose up -d
}
defectdojo_install
