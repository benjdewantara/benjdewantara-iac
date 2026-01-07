#!/usr/bin/env bash

echo "This is the start of bnj-directus-tutor\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent

echo "This is the end of bnj-directus-tutor\user_data.sh"
