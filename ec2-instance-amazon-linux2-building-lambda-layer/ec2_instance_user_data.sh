#!/bin/bash
set -x

sudo -s

filenameResultBefore="/root/result-before.txt"
filenameResultAfter="/root/result-after.txt"

touch $filenameResultBefore
touch $filenameResultAfter

yum update -y

PATH_BINS=(
    "/bin/"
    "/usr/local/bin/"
    "/usr/bin/"
    "/usr/local/sbin/"
    "/usr/sbin/"
)

for dirpath in ${PATH_BINS[@]}; do
    find $dirpath -type f >>$filenameResultBefore
done

yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

for dirpath in ${PATH_BINS[@]}; do
    find $dirpath >>$filenameResultAfter
done
