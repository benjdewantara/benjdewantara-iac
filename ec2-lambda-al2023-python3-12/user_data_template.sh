#!/usr/bin/env sh

echo "This is the start of ec2-lambda-al2023-python3-12/user_data_template.sh"
sudo -s
set -x

HOME="/home/ec2-user"
python3version="python3.12"

cd || exit

touch "$HOME/timestamp-before-isntalling-python-3-12"
yum update -y

yum install -y pip
yum install -y $python3version

pip install --user pipenv

virtualenv -p /usr/bin/$python3version python312custom
# shellcheck disable=SC3046
source $HOME/python312custom/bin/activate
pip install docker
