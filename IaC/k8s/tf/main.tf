# Create Hetzner Cloud SSH Key Resource
module "project_hetzner_ssh_key" {
  source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudSSHKey"
  labels = var.labels
  name   = var.admin_ssh_key_name
  public_key = file(var.admin_ssh_key)
}

# Create Cloudflare Api Token for External DNS
module "project_cloudflare_api_token" {
  source   = "git@github.com:thanos1983/terraform//Cloudflare/modules/ApiToken"
  status   = var.status
  policies = local.cloudflare_policies
  name     = var.cloudflare_api_token_name
}

# Create Hetzner Cloud Placement Group
# module "project_hetzner_placement_group" {
#   source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudPlacementGroup"
#   type   = "spread"
#   labels = var.labels
#   name   = "my-placement-group"
# }

# Create Hetzner Cloud Network
module "project_hetzner_network" {
  source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudNetwork"
  labels   = var.labels
  name     = local.network.virtual_network.name
  ip_range = local.network.virtual_network.ip_range
}

# Create Hetzner Cloud Network Subnets
module "project_hetzner_subnet" {
  source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudNetworkSubnet"
  network_id   = module.project_hetzner_network.id
  type         = local.network.virtual_network.subnet.k8s.type
  ip_range     = local.network.virtual_network.subnet.k8s.ip_range
  network_zone = local.network.virtual_network.subnet.k8s.network_zone
}

# Create Hetzner Primary IP(s) (Public IPs)
module "project_hetzner_primary_ip" {
  source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudPrimaryIP"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  labels        = var.labels
  name          = each.value.public_ip.name
  type          = each.value.public_ip.type
  datacenter    = each.value.public_ip.datacenter
  assignee_type = each.value.public_ip.assignee_type
}

# Create Hetzner Server(s) and assign IP(s) (Public IPs)
module "project_hetzner_server" {
  source = "git@github.com:thanos1983/terraform//Hetznercloud/modules/HetznerCloudServer"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  labels      = var.labels
  name        = each.value.linux_virtual_machine.name
  image       = each.value.linux_virtual_machine.image
  location = each.value.linux_virtual_machine.location
  # placement_group_id = module.project_hetzner_placement_group.id
  user_data   = each.value.linux_virtual_machine.user_data
  server_type = each.value.linux_virtual_machine.server_type
  public_net_block = {
    ipv4_enabled = true
    ipv6_enabled = false
    ipv4         = module.project_hetzner_primary_ip[each.key].id
  }
  network_blocks = [
    {
      ip         = each.value.network.ip
      network_id = module.project_hetzner_network.id
    }
  ]
  ssh_keys = [module.project_hetzner_ssh_key.id]
  depends_on = [
    module.project_hetzner_subnet
  ]
}

# Create DNS record for Knative domain(s)
module "project_knative_dns_records" {
  source = "git@github.com:thanos1983/terraform//Cloudflare/modules/DnsRecord"
  for_each = local.cloudFlareTypeDnsRecord
  zone_id  = var.CLOUDFLARE_ZONE_ID
  content  = each.value.content
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
}

# Ansible roles to deploy HAProxy node(s)
module "project_k8s_ansible_playbook_load_balancer" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  for_each   = local.haPoxyLoadBalancer
  playbook   = var.playbook
  replayable = var.replayable
  tags       = each.value.tags
  name       = module.project_hetzner_server[each.key].ipv4_address
  extra_vars = {
    ansible_user = var.username
  }
}

# Ansible roles to deploy Master and Worker nodes
module "project_k8s_ansible_playbook" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  for_each = merge(local.master_nodes, local.worker_nodes)
  playbook   = var.playbook
  replayable = var.replayable
  tags       = each.value.tags
  name       = module.project_hetzner_server[each.key].ipv4_address
  extra_vars = {
    domain                = var.zone
    ansible_user          = var.username
    serviceCidr           = var.serviceCidr
    faasNamespace         = var.faasNamespace
    istioNamespace        = var.istioNamespace
    podNetworkCidr        = var.podNetworkCidr
    lb_stats_uri_path     = var.haProxyStatsUriPath
    certManagerNamespace  = var.certManagerNamespace
    lb_stats_bind_port    = var.haProxyStatsBindPort
    kubeConfigDestination = var.kubeConfigDestination
    kube_api_bind_port    = var.kubeServerApiServerBindPort
    secretName            = var.cloudflare_secretKeyRef_name
    secretValue           = module.project_cloudflare_api_token.value
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
    lb_ip_address         = module.project_hetzner_server["haProxyLB"].ipv4_address
  }
  depends_on = [
    module.project_k8s_ansible_playbook_load_balancer
  ]
}

# Applying all helm module(s) deployment(s)
module "project_k8s_cluster_helm_deployment_dependencies" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  for_each          = local.helm_deployment_dependencies
  wait              = each.value.wait
  name              = each.value.name
  chart             = each.value.chart
  force_update      = var.force_update
  values            = each.value.values
  helm_version      = each.value.version
  namespace         = each.value.namespace
  dependency_update = var.dependency_update
  repository        = each.value.repository
  set_blocks        = each.value.set_blocks
  wait_for_jobs     = each.value.wait_for_jobs
  create_namespace  = each.value.create_namespace
  depends_on = [
    module.project_k8s_ansible_playbook
  ]
}

# Create desired CertManager Cluster Issuer(s)
module "project_k8s_ansible_playbook_cert_manager_cluster_issuer" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  tags = ["k8sAnsible"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_hetzner_server["master01"].ipv4_address
  extra_vars = {
    domain       = var.zone
    ansible_user = var.username
    acme_email   = var.CLOUDFLARE_EMAIL
    secretKeyRef = var.cloudflare_secretKeyRef_key
    secretName   = var.cloudflare_secretKeyRef_name
  }
  depends_on = [
    module.project_k8s_cluster_helm_deployment_dependencies
  ]
}

# Master
# kubeadm join <load balancer IP>:<API port> --token <token> \
#         (--discovery-token-ca-cert-hash sha256:<hash value>) or (--discovery-token <hex value>) \
#         --control-plane --token-ttl 10m

# Worker
# kubeadm join <load balancer IP>:<API port> --token <token> \
#         (--discovery-token-ca-cert-hash sha256:<hash value>) or (--discovery-token <hex value>)

# sudo kubeadm reset -f
# kubectl label node <worker> kubernetes.io/role=worker
