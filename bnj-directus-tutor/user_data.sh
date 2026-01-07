#!/usr/bin/env bash

echo "This is the start of bnj-directus-tutor\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent
yum install -y docker
yum install -y git

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

echo "This is the end of bnj-directus-tutor\user_data.sh"
