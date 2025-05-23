installation:
  kubeletVolumePluginPath: none
  registry: "quay.io/"
  imagePath: "calico"
  cni:
    type: "Calico"
  calicoNetwork:
    bgp: "Disabled"
    ipPools:
      - cidr: "${podNetworkCidr}"
        encapsulation: "VXLAN"

tigeraOperator:
  image: "tigera/operator"
  registry: "quay.io"

calicoctl:
  image: "quay.io/calico/ctl"
