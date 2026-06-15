#!/usr/bin/env bash

app_domain='${app_domain}'
projectname='${projectname}'
github_pat='${github_pat}'

app_uri="http://$app_domain:8080"
app_uri_backslash_escaped=$(echo $app_uri | sed -E -s ' s/\//\\\//g ')

echo "This is the start of bnj-golang-gin-tutor\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent
yum install -y docker
yum install -y git
yum install -y nc
yum install -y jq
yum install -y go
# thanks to https://unix.stackexchange.com/a/249495/186480
# use `yum list` to discover the exact `postgresql16.x86_64`
yum install -y postgresql16.x86_64

create_dummy_service_unit() {
  local filename_shell_script="$projectname.sh"
  local filename_service_unit="$projectname.service"

  cat <<EOF >/home/ec2-user/$filename_shell_script
#!/bin/bash
cd /home/ec2-user/app && go run .
EOF

  chmod +x /home/ec2-user/app/plain/server.sh
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
Restart=always
Environment="SERVER_DIR=/home/ec2-user/app/plain"
Environment=PORT=8081
WorkingDirectory=/home/ec2-user/app/plain
RestartSec=15s

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable /home/ec2-user/$filename_service_unit
  systemctl start $filename_service_unit
}
create_dummy_service_unit

logfrom_jctl() {
  local service_unit_name_target=$1
  service_unit_name_target=$${service_unit_name_target%.service}
  local app_log_filepath="/var/log/app-$service_unit_name_target.log"

  local logfrom_jctl_dir="/home/ec2-user/.logfrom_jctl"
  local logfrom_jctl_service_unit_name="logfrom_jctl-$service_unit_name_target.service"
  local logfrom_jctl_service_unit_file="$logfrom_jctl_dir/$logfrom_jctl_service_unit_name"
  local logfrom_jctl_script="$logfrom_jctl_dir/logfrom_jctl-$service_unit_name_target.sh"

  mkdir -p $logfrom_jctl_dir

  cat <<EOF >$logfrom_jctl_script
#!/bin/bash
journalctl -u $service_unit_name_target --cursor-file '$logfrom_jctl_dir/$service_unit_name_target.cursor' >> $app_log_filepath
EOF

  chmod +x $logfrom_jctl_script

  cat <<EOF >$logfrom_jctl_service_unit_file
# Copyright Benyamin Manullang. All Rights Reserved.

[Unit]
Description=logfrom_jctl that creates log textfiles from given by journalctl
After=network.target

[Service]
Type=simple
ExecStart=$logfrom_jctl_script
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable $logfrom_jctl_service_unit_file
  systemctl start $logfrom_jctl_service_unit_name

  chown -R ec2-user $logfrom_jctl_dir
}
logfrom_jctl "benj-svc-01a.service"

clone_app_repository() {
  git clone '${uri_app_repository}' /home/ec2-user/app
  # cd /home/ec2-user && git clone '${uri_app_repository}'

  while IFS= read -r -d '' file; do
    # shellcheck disable=SC2016
    echo "Will replace $file"
    sed -i $file -E -e "s/%APP_URI%/$app_uri_backslash_escaped/g"
  done < <(find '/home/ec2-user/app' -mtime -7 -name '*.html' -print0)

  chown -R ec2-user: /home/ec2-user
  find /home/ec2-user/app -type f -name '*.sh' -exec chmod +x {} \;
}
clone_app_repository

adjust_personal_prefs() {
  local dir_home="/home/ec2-user"

  if [[ -n $github_pat ]]; then
    mkdir -p "$dir_home"
    echo "export github_pat=$github_pat" >>$dir_home/.bashrc
    chown -R ec2-user $dir_home/.bashrc
  fi

  echo 'set completion-ignore-case On' >>$dir_home/.inputrc
  echo 'alias ll="ls -tral"' >>$dir_home/.bashrc

  chown -R ec2-user: $dir_home/.inputrc
  chown -R ec2-user: $dir_home/.bashrc
}
adjust_personal_prefs

echo "This is the end of bnj-golang-gin-tutor\user_data.sh"
