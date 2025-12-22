#!/usr/bin/env sh

echo "This is the start of ./ec2-nodejs-cloudwatch-agent-logs/locals.tf"

set -x

whoami

yum update -y
yum install -y amazon-cloudwatch-agent

# The config file is also located at /opt/aws/amazon-cloudwatch-agent/bin/config.json.
filepath_cwagent_config_json="/opt/aws/amazon-cloudwatch-agent/bin/config.json"
echo '${cwagent_config_json}' >$filepath_cwagent_config_json

# read https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/start-CloudWatch-Agent-on-premise-SSM-onprem.html
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 -s \
  -c file:$filepath_cwagent_config_json

echo "This is the end of ./ec2-nodejs-cloudwatch-agent-logs/locals.tf"
