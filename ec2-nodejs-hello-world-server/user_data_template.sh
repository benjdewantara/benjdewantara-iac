#!/bin/bash

echo "This is the start of ec2-nodejs-hello-world-server/user_data_template.sh"

#HOME="/home/ec2-user"
#HOME="/root"

#set -x

#sudo su ec2-user
#whoami
#echo $HOME
#cd $HOME || exit

yum update -y
yum install -y git
yum install -y nodejs

cd /home/ec2-user
git clone --branch '${git_branch}' '${git_repo_url}' ./project_app

NODE_APP_FULLFILEPATH=`find ./project_app -maxdepth 2 -type f -iregex .*package.json | head -n 1`
NODE_APP_DIR=`dirname $NODE_APP_FULLFILEPATH`
cd $NODE_APP_DIR

#npm run start

#export NVM_DIR="/home/ec2-user/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#
## Download and install nvm:
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
#
## in lieu of restarting the shell
#\. "$HOME/.nvm/nvm.sh"
#
## Download and install Node.js:
#nvm install 22
#
## Verify the Node.js version:
#node -v # Should print "v22.17.1".
#nvm current # Should print "v22.17.1".
#
## Verify npm version:
#npm -v # Should print "10.9.2".
#
## Should automatically install latest npm
#npm install -g npm
