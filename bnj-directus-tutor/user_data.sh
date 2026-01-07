#!/usr/bin/env bash

echo "This is the start of bnj-directus-tutor\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent
yum install -y docker
yum install -y git
yum install -y nc
# thanks to https://unix.stackexchange.com/a/249495/186480
# use `yum list` to discover the exact `postgresql16.x86_64`
yum install -y postgresql16.x86_64

install_node_npm_as_ec2user() {
  cd /home/ec2-user || exit

  # Download and install nvm:
  set -x
  export NVM_DIR="/home/ec2-user/.nvm"
  mkdir -p $NVM_DIR
  set +x

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

  # Download and install Node.js:
  nvm install 24

  # Verify the Node.js version:
  node -v

  # Verify npm version:
  npm -v

  npm install -g npm

  chown -R ec2-user: /home/ec2-user/.nvm

  dir_bin_node=$(find /home/ec2-user/.nvm/ -type d -iregex ".*versions.*bin" | head -n 1)
  echo "export PATH=\$PATH:$dir_bin_node" >>/home/ec2-user/.bashrc
}

install_node_npm_as_ec2user

install_followup_docker_compose() {
  DOCKER_CONFIG="/usr/libexec/docker"
  mkdir -p $DOCKER_CONFIG/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
  chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
}

install_followup_docker_compose

install_followup_docker() {
  usermod -a -G docker ec2-user

  # bash-completion for docker
  curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

  systemctl start docker
  systemctl enable docker.service
  systemctl enable containerd.service
}

install_followup_docker

git clone '${uri_app_repository}' /home/ec2-user/app

echo "This is the end of bnj-directus-tutor\user_data.sh"
