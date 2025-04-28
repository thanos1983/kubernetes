#!/bin/bash
set -e

K8S_TOKEN=$(kubeadm token generate)
K8S_CERTS=$(kubeadm certs certificate-key)
jq -n --arg k8s_token "$K8S_TOKEN" --arg k8s_certs "$K8S_CERTS" '{"k8s_token":$k8s_token,"k8s_certs":$k8s_certs}'
