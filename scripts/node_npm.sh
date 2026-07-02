#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p "$dir_user"

set -x
yum update -y

install_node_npm() {
  # this is basically https://nodejs.org/en/download

  cd "$dir_user" || exit

  export NVM_DIR="$dir_user/.nvm"
  mkdir -p $NVM_DIR

  set +x # undo setting xtrace option for now

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  nvm install 24
  node -v
  npm -v
  npm install -g npm

  set -x # back to using xtrace option

  chown -R ec2-user: "$dir_user/.nvm"
  dir_bin_node=$(find "$dir_user/.nvm/" -type d -iregex ".*versions.*bin" | head -n 1)
  echo "export PATH=\$PATH:$dir_bin_node" >>"$dir_user/.bashrc"
}
install_node_npm
