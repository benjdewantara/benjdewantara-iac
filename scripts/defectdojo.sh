#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user
git_uri_defectdojo='${git_uri_defectdojo}'

set -x
yum update -y
yum install -y git

defectdojo_install() {
  cd "$dir_user" || exit
  set +x
  git clone $git_uri_defectdojo
  set -x
  chown -R ec2-user: $dir_user

  local dir_git="$${git_uri_defectdojo##*/}"
  dir_git="$${dir_git%.git}"

  cd "$dir_git" || exit
  docker compose up -d
}
defectdojo_install

defectdojo_wait_until_admin_password() {
  cd "$dir_user" || exit

  local dir_git="$${git_uri_defectdojo##*/}"
  dir_git="$${dir_git%.git}"

  cd "$dir_git" || exit

  local indx=0
  while [ $indx -lt 100 ]; do
    ((indx++))
    sleep 10

    echo "indx=$indx Will check if admin password already exists.."
    local password=$(docker compose logs initializer | grep "Admin password:")
    [[ -n $password ]] && break
    echo "indx=$indx Admin password is not generated yet"
  done
}
defectdojo_wait_until_admin_password
