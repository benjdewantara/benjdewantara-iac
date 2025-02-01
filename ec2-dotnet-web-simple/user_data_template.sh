#!/bin/bash

set -x
sudo -s

yum update -y

yum install -y git socat iptables
yum install -y dotnet

#exit

mkdir -p '/home/ec2-user'
cd '/home/ec2-user'
git clone '${git_dotnet_project}'

filename_csproj=`find . -type f -iregex .*csproj | head -n 1`
filename_csproj=`realpath $filename_csproj`

dirname_csproj=`dirname $filename_csproj`

cd $dirname_csproj
#dotnet run

#exit 0
