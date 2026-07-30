#!/bin/bash

dir_user='/home/ec2-user' && mkdir -p $dir_user

set -x
yum update -y

# read https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
kubelet_kubeadm_kubectl() {
  # Set SELinux in permissive mode (effectively disabling it)
  #sudo setenforce 0
  #sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

  # This overwrites any existing configuration in /etc/yum.repos.d/kubernetes.repo
  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.36/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.36/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

  sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

  sudo systemctl enable --now kubelet
}
kubelet_kubeadm_kubectl
