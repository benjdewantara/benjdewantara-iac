#!/usr/bin/env sh

echo "This is the start of ec2-nodejs-hello-world-server/user_data_template.sh"

HOME="/home/ec2-user"

set -x

cd $HOME || exit

yum update -y

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.17.1".
nvm current # Should print "v22.17.1".

# Verify npm version:
npm -v # Should print "10.9.2".

# Should automatically install latest npm
npm install -g npm
