#!/usr/bin/env bash

app_domain='${app_domain}'
github_pat='${github_pat}'

if [[ -n $github_pat ]]; then
  mkdir -p '/home/ec2-user'
  echo "export github_pat=$github_pat" >>/home/ec2-user/.bashrc
  chown -R ec2-user: '/home/ec2-user'
fi

echo "This is the start of bnj-directus-tutor\user_data.sh"

set -x
yum update -y
yum install -y amazon-cloudwatch-agent
yum install -y docker
yum install -y git
yum install -y nc
# thanks to https://unix.stackexchange.com/a/249495/186480
# use `yum list` to discover the exact `postgresql16.x86_64`
yum install -y postgresql16.x86_64

create_dummy_service_unit() {
  local filename_shell_script="bnj-directus-frontend-plain-html.sh"
  local filename_service_unit="bnj-directus-frontend-plain-html.service"

  cat <<EOF >/home/ec2-user/$filename_shell_script
#!/bin/bash
while [[ 1 ]]; do
  /home/ec2-user/app/plain/server.sh | nc -l 0.0.0.0 3000;
done;
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

install_node_npm_as_ec2user() {
  cd /home/ec2-user || exit

  # Download and install nvm:
  set -x
  export NVM_DIR="/home/ec2-user/.nvm"
  mkdir -p $NVM_DIR
  set +x

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

  # Download and install Node.js:
  nvm install 24

  # Verify the Node.js version:
  node -v

  # Verify npm version:
  npm -v

  npm install -g npm

  chown -R ec2-user: /home/ec2-user/.nvm

  dir_bin_node=$(find /home/ec2-user/.nvm/ -type d -iregex ".*versions.*bin" | head -n 1)
  echo "export PATH=\$PATH:$dir_bin_node" >>/home/ec2-user/.bashrc
}
install_node_npm_as_ec2user

install_pnpm() {
  echo "Will install_pnpm"

  curl -fsSL https://get.pnpm.io/install.sh | sh -

  local dir_pnpm='/home/ec2-user/.local/share/pnpm'
  mkdir -p $dir_pnpm
  cp -r '/root/.local/share/pnpm/'* '/root/.local/share/pnpm/.'* $dir_pnpm
  chown -R ec2-user: '/home/ec2-user/.local'
  echo "export PATH=\$PATH:$dir_pnpm" >>/home/ec2-user/.bashrc

  echo "Finished install_pnpm"
}
install_pnpm

install_followup_docker_compose() {
  DOCKER_CONFIG="/usr/libexec/docker"
  mkdir -p $DOCKER_CONFIG/cli-plugins
  curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
  chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
}
install_followup_docker_compose

install_followup_docker() {
  usermod -a -G docker ec2-user

  # bash-completion for docker
  curl https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker.sh

  systemctl start docker
  systemctl enable docker.service
  systemctl enable containerd.service
}
install_followup_docker

git clone '${uri_app_repository}' /home/ec2-user/app
cd /home/ec2-user && git clone '${uri_app_repository}'
chown -R ec2-user: /home/ec2-user
find /home/ec2-user/app -type f -iregex '.*.sh' -exec chmod +x {} \;

dir_current=$(realpath .)
dir_directus=$(find '/home/ec2-user/app' -type d -iregex '.*directus' | head -n 1)
dir_frontend=$(find '/home/ec2-user/app' -type d -iregex '.*nextjs' | head -n 1)

replace_localhost_with_app_domain() {
  echo "Will replace_localhost_with_app_domain"
  [[ -z $app_domain ]] && echo "app_domain is not set, will not perform replacement" && return

  local f="$dir_directus/.env"
  sed -i "$f" -E -e " /PUBLIC_URL=/! b ; s/localhost/$app_domain/g "
  sed -i "$f" -E -e " /REFRESH_TOKEN_COOKIE_DOMAIN=/! b ; s/localhost/$app_domain/g "
  sed -i "$f" -E -e " /SESSION_COOKIE_DOMAIN=/! b ; s/localhost/$app_domain/g "
  sed -i "$f" -E -e " /CONTENT_SECURITY_POLICY_DIRECTIVES__FRAME_SRC=/! b ; s/(http:\/\/)(localhost)(:[[:digit:]]+)/\0,\1$app_domain\3/g "

  local f="$dir_frontend/.env"
  sed -i "$f" -E -e " /NEXT_PUBLIC_DIRECTUS_URL=/! b ; s/localhost/$app_domain/g "
  sed -i "$f" -E -e " /NEXT_PUBLIC_SITE_URL=/! b ; s/localhost/$app_domain/g "
}
replace_localhost_with_app_domain

echo "Will do 'docker compose up' on $dir_directus"
cd "$dir_directus" && docker compose up -d
# shellcheck disable=SC2164
cd "$dir_current"

adjust_personal_prefs() {
  local dir_home="/home/ec2-user"

  echo 'set completion-ignore-case On' >>$dir_home/.inputrc
  echo 'alias ll="ls -tral"' >>$dir_home/.bashrc

  chown -R ec2-user: $dir_home/.inputrc
  chown -R ec2-user: $dir_home/.bashrc
}
adjust_personal_prefs

echo "This is the end of bnj-directus-tutor\user_data.sh"
