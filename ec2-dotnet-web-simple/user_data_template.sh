#!/bin/bash

set -x
sudo -s

yum update -y

yum install -y git socat iptables
yum install -y dotnet

#exit

export HOME="/home/ec2-user"
mkdir -p $HOME
cd $HOME
git clone '${git_dotnet_project}'

filename_csproj=$(find . -type f -iregex .*csproj | head -n 1)
filename_csproj=$(realpath $filename_csproj)

dirname_csproj=$(dirname $filename_csproj)

cd $dirname_csproj

filename_launchSettingsJson=$(find . -type f -iregex .*launchSettings.json | head -n 1)
mv $filename_launchSettingsJson{,.bak}

dotnet publish --configuration Release --output /var/www/dotnetwebapp

CERT_PATH="$HOME/cert.pfx"
CERT_PASS="Pass123#"
dotnet dev-certs https -p $CERT_PASS -ep "$CERT_PATH"

read -r -d '' insertThis <<EOM
[Unit]
Description=Example .NET Web API App running on Linux

[Service]
WorkingDirectory=/var/www/dotnetwebapp
ExecStart=/usr/bin/dotnet /var/www/dotnetwebapp/dotnetwebapp.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnetwebapp
User=root
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_HTTP_PORTS=80
Environment=ASPNETCORE_HTTPS_PORTS=443
Environment=ASPNETCORE_URLS=http://*:80/;https://*:443/
Environment=DOTNET_NOLOGO=true
Environment=Kestrel__Certificates__Default__Path=$CERT_PATH
Environment=Kestrel__Certificates__Default__Password=$CERT_PASS

[Install]
WantedBy=multi-user.target
EOM

echo "$insertThis" >/etc/systemd/system/dotnetwebapp.service

systemctl enable dotnetwebapp.service
systemctl start dotnetwebapp.service
systemctl status dotnetwebapp.service

#exit 0
