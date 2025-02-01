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

read -r -d '' insertThis <<EOM
[Unit]
Description=Example .NET Web API App running on Linux

[Service]
WorkingDirectory1=$dirname_csproj
ExecStart1=/usr/bin/dotnet run --project $dirname_csproj
WorkingDirectory=/var/www/dotnetwebapp
ExecStart=/usr/bin/dotnet /var/www/dotnetwebapp/dotnetwebapp.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-example
User=root
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_HTTP_PORTS=80
Environment=ASPNETCORE_URLS=http://*:80/
Environment=DOTNET_NOLOGO=true

[Install]
WantedBy=multi-user.target
EOM

echo "$insertThis" >/etc/systemd/system/dotnetwebapp.service

systemctl enable dotnetwebapp.service
systemctl start dotnetwebapp.service
systemctl status dotnetwebapp.service

#exit 0
