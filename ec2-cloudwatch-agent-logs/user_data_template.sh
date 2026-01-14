#!/usr/bin/env sh

echo "This is the start of ./ec2-nodejs-cloudwatch-agent-logs/locals.tf"

set -x

whoami

yum update -y
yum install -y amazon-cloudwatch-agent

install_cloudwatch_agent() {
  echo "Will install_cloudwatch_agent"

  # The config file is also located at /opt/aws/amazon-cloudwatch-agent/bin/config.json.
  local filepath_user_data_cwagent_config_json="/opt/aws/amazon-cloudwatch-agent/bin/config.json"
  echo '${user_data_cwagent_config_json_base64}' | base64 --decode >"$filepath_user_data_cwagent_config_json"

  # read https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/start-CloudWatch-Agent-on-premise-SSM-onprem.html
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 -s \
    -c file:$filepath_user_data_cwagent_config_json
}
install_cloudwatch_agent

filename_shell_script="benj-shell-app-01a.sh"
filename_service_unit="benj-svc-01a.service"

cat <<EOF >/home/ec2-user/$filename_shell_script
#!/bin/bash
while [[ 1 ]];
do
  d="\$(date --rfc-email)";
  echo "Hello world at \$d " >> /var/log/app.log;
  sleep 3;
done;
EOF

chmod +x /home/ec2-user/$filename_shell_script

cat <<EOF >/home/ec2-user/$filename_service_unit
# Copyright Benyamin Manullang. All Rights Reserved.

[Unit]
Description=Benj test
After=network.target

[Service]
Type=simple
ExecStart=/home/ec2-user/$filename_shell_script
KillMode=process
Restart=on-failure
RestartSec=60s

[Install]
WantedBy=multi-user.target
EOF

sed -i /home/ec2-user/$filename_service_unit -E -e " s/%%filename_shell_script%%/$filename_shell_script/ "

systemctl enable /home/ec2-user/$filename_service_unit
systemctl start $filename_service_unit

echo "This is the end of ./ec2-nodejs-cloudwatch-agent-logs/locals.tf"
