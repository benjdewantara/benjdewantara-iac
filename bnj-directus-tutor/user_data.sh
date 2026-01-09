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
chown -R ec2-user: /home/ec2-user/app

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
  sed -i "$f" -E -e " /CONTENT_SECURITY_POLICY_DIRECTIVES__FRAME_SRC=/! b ; s/localhost/$app_domain/g "

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
