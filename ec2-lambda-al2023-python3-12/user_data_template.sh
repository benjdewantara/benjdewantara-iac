#!/usr/bin/env sh

echo "This is the start of ec2-lambda-al2023-python3-12/user_data_template.sh"

HOME="/home/ec2-user"
python3version="python3.12"
project_name="python312custom"

#sudo -s # user data already sudo apparently
set -x

cd $HOME || exit

touch "$HOME/timestamp-before-isntalling-python-3-12"

yum update -y
yum install -y $python3version
yum install -y pip

pip install --user pipenv

/root/.local/bin/virtualenv -p /usr/bin/$python3version $project_name
# shellcheck disable=SC3046
source $HOME/$project_name/bin/activate
pip install docker

cd $HOME || exit
zip $project_name.zip -r $project_name
aws s3 cp ./$project_name.zip "${s3_uri_dump_results_trimmed}/$project_name.zip"
