#!/usr/bin/env bash

echo "This is the start of ec2-pub-postgres\user_data.sh"

dir_user='/home/ec2-user' && mkdir -p $dir_user
pg_hba_filename='/var/lib/pgsql/data/pg_hba.conf'
pg_hba_filename_bak="$pg_hba_filename.bak"

set -x
yum update -y

output_states_to_file() {
  timestamp_txt=$(date --rfc-3339=s | sed -E -e ' s/\+.+//g ; s/\W//g')
  find /usr/ /etc/ -type f >"$dir_user/$timestamp_txt.usr-etc-content"
  systemctl list-units >"$dir_user/$timestamp_txt.systemctl-list-units"
}

# initial state
output_states_to_file

yum install -y postgresql18.x86_64
output_states_to_file

yum install -y postgresql18-server.x86_64
output_states_to_file

postgresql-setup --initdb

cp $pg_hba_filename $pg_hba_filename_bak

systemctl enable postgresql.service
systemctl start postgresql.service

postgres_db_user_authenticate_with_password_wkwk() {
  sudo -u postgres psql -c "ALTER USER postgres with password 'wkwk';"
  sed -i $pg_hba_filename -E -e ' s/(^local\s+.+\s)(\w+$)/\1md5/ '
  systemctl reload postgresql.service
}
#postgres_db_user_authenticate_with_password_wkwk

# read https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
postgres_db_user_authenticate_unconditionally() {
  sed -i $pg_hba_filename -E -e ' s/(^local\s+.+\s)(\w+$)/\1trust/ '
  sed -i $pg_hba_filename -E -e ' s/(^host\s+.+\s)(\w+$)/\1trust/ '
  systemctl reload postgresql.service
}
postgres_db_user_authenticate_unconditionally

# documentations and articles that I read
# https://www.postgresql.org/files/documentation/pdf/18/postgresql-18-US.pdf
# https://stackoverflow.com/questions/18664074/getting-error-peer-authentication-failed-for-user-postgres-when-trying-to-ge
# https://stackoverflow.com/questions/27107557/what-is-the-default-password-for-postgres

# postgresql running
output_states_to_file

cd "$dir_user" || exit

# download zitadel
set +x
LATEST=$(curl -i https://github.com/zitadel/zitadel/releases/latest | grep location: | cut -d '/' -f 8 | tr -d '\r')
ARCH=$(uname -m)
case $ARCH in armv5*) ARCH="armv5" ;; armv6*) ARCH="armv6" ;; armv7*) ARCH="arm" ;; aarch64) ARCH="arm64" ;; x86) ARCH="386" ;; x86_64) ARCH="amd64" ;; i686) ARCH="386" ;; i386) ARCH="386" ;; esac
wget -c https://github.com/zitadel/zitadel/releases/download/$LATEST/zitadel-linux-$ARCH.tar.gz -O - | tar -xz && sudo mv zitadel-linux-$ARCH/zitadel /usr/local/bin
set -x
output_states_to_file

# run zitadel (dont't do this on user data)
# taken from https://zitadel.com/docs/self-hosting/deploy/linux
run_zitadel_root_user() {
  ZITADEL_DATABASE_POSTGRES_DSN=postgresql://root:postgres@localhost:5432/postgres?sslmode=disable ZITADEL_EXTERNALSECURE=false zitadel start-from-init --masterkey "MasterkeyNeedsToHave32Characters" --tlsMode disabled
}

run_zitadel_postgres_user() {
  ZITADEL_DATABASE_POSTGRES_DSN=postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable ZITADEL_EXTERNALSECURE=false zitadel start-from-init --masterkey "MasterkeyNeedsToHave32Characters" --tlsMode disabled
}

# only `run_zitadel_postgres_user` seems to work
# notice the connection string difference

chown -R ec2-user: $dir_user

echo "This is the end of ec2-pub-postgres\user_data.sh"
