#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

docker_install() {
  yum install -y docker
}
docker_install

docker_compose_install() {
  local DOCKER_CONFIG="/usr/libexec/docker"
  mkdir -p $DOCKER_CONFIG/cli-plugins
  set +x
  curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
  set -x
  chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
}
docker_compose_install

docker_bash_completion_install() {
  usermod -a -G docker ec2-user

  # bash-completion for docker
  set +x
  curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh
  set -x
}
docker_bash_completion_install

docker_enable_install() {
  systemctl start docker
  systemctl enable docker.service
  systemctl enable containerd.service
}
docker_enable_install
