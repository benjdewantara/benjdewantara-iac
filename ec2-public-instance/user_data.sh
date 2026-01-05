#!/usr/bin/env bash

echo "This is the start of ec2-public-instance\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent

echo "This is the end of ec2-public-instance\user_data.sh"