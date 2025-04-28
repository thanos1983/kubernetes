#!/bin/bash
set -e

# For Jammy 22.04 LTS
# Versions info https://haproxy.debian.net/#distribution=Ubuntu&release=jammy&version=3.0
CRIO_VERSION="v1.30"
KUBERNETES_VERSION="v1.30"

sudo touch /etc/modules-load.d/k8s.conf
sudo echo "overlay" | sudo tee -a /etc/modules-load.d/k8s.conf > /dev/null
sudo echo "br_netfilter" | sudo tee -a /etc/modules-load.d/k8s.conf > /dev/null

sudo touch /etc/sysctl.d/k8s.conf
sudo echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/k8s.conf > /dev/null
sudo echo "net.bridge.bridge-nf-call-iptables  = 1" | sudo tee -a /etc/sysctl.d/k8s.conf > /dev/null
sudo echo "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/k8s.conf > /dev/null

sudo DEBIAN_FRONTEND=noninteractive modprobe overlay
sudo DEBIAN_FRONTEND=noninteractive modprobe br_netfilter
sudo DEBIAN_FRONTEND=noninteractive sysctl --system

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates curl libbtrfs-dev git libassuan-dev libglib2.0-dev libc6-dev libgpgme-dev libgpg-error-dev libseccomp-dev libsystemd-dev libselinux1-dev pkg-config go-md2man libudev-dev software-properties-common gcc make socat gpg

sudo DEBIAN_FRONTEND=noninteractive rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo DEBIAN_FRONTEND=noninteractive curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/Release.key | sudo DEBIAN_FRONTEND=noninteractive gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo DEBIAN_FRONTEND=noninteractive echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /" | sudo DEBIAN_FRONTEND=noninteractive tee /etc/apt/sources.list.d/kubernetes.list

sudo DEBIAN_FRONTEND=noninteractive rm -f /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo DEBIAN_FRONTEND=noninteractive curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/${CRIO_VERSION}/deb/Release.key | sudo DEBIAN_FRONTEND=noninteractive gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
sudo DEBIAN_FRONTEND=noninteractive echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/${CRIO_VERSION}/deb/ /" | sudo DEBIAN_FRONTEND=noninteractive tee /etc/apt/sources.list.d/cri-o.list

sudo DEBIAN_FRONTEND=noninteractive apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y cri-o kubelet kubeadm kubectl

sudo DEBIAN_FRONTEND=noninteractive systemctl start crio.service
sudo DEBIAN_FRONTEND=noninteractive systemctl enable --now crio
sudo DEBIAN_FRONTEND=noninteractive systemctl enable --now kubelet

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y containernetworking-plugins
sudo DEBIAN_FRONTEND=noninteractive rm -f /etc/crio/crio.conf.d/10-network-crio.conf
sudo DEBIAN_FRONTEND=noninteractive echo "" | sudo tee -a /etc/crio/crio.conf.d/10-network-crio.conf > /dev/null
sudo DEBIAN_FRONTEND=noninteractive echo "[crio.network]" | sudo tee -a /etc/crio/crio.conf.d/10-network-crio.conf > /dev/null
sudo DEBIAN_FRONTEND=noninteractive echo "network_dir = \"/etc/cni/net.d/\"" | sudo tee -a /etc/crio/crio.conf.d/10-network-crio.conf > /dev/null
sudo DEBIAN_FRONTEND=noninteractive echo "plugin_dirs = [\"/opt/cni/bin/\",\"/usr/lib/cni/\"]" | sudo tee -a /etc/crio/crio.conf.d/10-network-crio.conf > /dev/null

sudo DEBIAN_FRONTEND=noninteractive systemctl restart crio
