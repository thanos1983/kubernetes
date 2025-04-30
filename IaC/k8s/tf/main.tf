# Create Resource Group
module "project_resource_group" {
  source              = "git@github.com:thanos1983/terraform//Azure/modules/ResourceGroup"
  tags                = var.tags
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create Cloudflare Api Token for External DNS
module "projekt_cloudflare_api_token" {
  source   = "git@github.com:thanos1983/terraform//Cloudflare/modules/ApiToken"
  status   = var.status
  policies = local.cloudflare_policies
  name     = var.cloudflare_api_token_name
}

# Create Network Security Group
module "project_network_security_group" {
  source               = "git@github.com:thanos1983/terraform//Azure/modules/NetworkSecurityGroup"
  tags                 = var.tags
  security_rule_blocks = local.security_rules
  name                 = var.network_security_group_name
  resource_group_name  = module.project_resource_group.name
  location             = module.project_resource_group.location
}

# Create virtual network
module "project_virtual_network" {
  source              = "git@github.com:thanos1983/terraform//Azure/modules/VirtualNetwork"
  tags                = var.tags
  name                = local.network.virtual_network.name
  resource_group_name = module.project_resource_group.name
  location            = module.project_resource_group.location
  address_space       = local.network.virtual_network.address_space
  subnet_blocks = [
    {
      security_group   = module.project_network_security_group.id
      name             = local.network.virtual_network.subnet.k8s.name
      address_prefixes = local.network.virtual_network.subnet.k8s.address_prefixes
    }
  ]
}

# Assign Network Security Group to the Subnet
# module "project_network_security_group_association" {
#  source                    = "git@github.com:thanos1983/terraform//Azure/modules/SubnetNetworkSecurityGroupAssociation"
#  network_security_group_id = module.project_network_security_group.id
#  subnet_id                 = module.project_virtual_network.subnet[0].id
# }

# Create Availability VM Set for Master node(s)
module "project_nodes_availability_set" {
  source                       = "git@github.com:thanos1983/terraform//Azure/modules/AvailabilitySet"
  tags                         = var.tags
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  resource_group_name          = module.project_resource_group.name
  location                     = module.project_resource_group.location
  name                         = var.master_nodes_availability_set_name
}

# Create public IP(s) for Master Node(s)
module "project_nodes_public_ips" {
  source              = "git@github.com:thanos1983/terraform//Azure/modules/PublicIP"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  tags                = var.tags
  sku                 = each.value.public_ip.sku
  name                = each.value.public_ip.name
  resource_group_name = module.project_resource_group.name
  domain_name_label   = each.value.public_ip.domain_name_label
  allocation_method   = each.value.public_ip.allocation_method
  location            = module.project_resource_group.location
}

# Create DNS record for Knative domain(s)
module "projekt_knative_dns_records" {
  source   = "git@github.com:thanos1983/terraform//Cloudflare/modules/DnsRecord"
  for_each = local.cloudFlareTypeDnsRecord
  zone_id  = var.CLOUDFLARE_ZONE_ID
  content  = each.value.content
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
}

# Create Network Interfaces for Master node(s)
module "project_nodes_network_interfaces" {
  source = "git@github.com:thanos1983/terraform//Azure/modules/NetworkInterface"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  tags   = var.tags
  name   = each.value.network_interface.name
  ip_configuration_blocks = [
    {
      subnet_id                     = module.project_virtual_network.subnet[0].id
      public_ip_address_id          = module.project_nodes_public_ips[each.key].id
      name                          = each.value.network_interface.ip_configuration.name
      private_ip_address            = each.value.network_interface.ip_configuration.private_ip_address
      private_ip_address_allocation = each.value.network_interface.ip_configuration.private_ip_address_allocation
    }
  ]
  accelerated_networking_enabled = var.accelerated_networking_enabled
  resource_group_name            = module.project_resource_group.name
  location                       = module.project_resource_group.location
  ip_forwarding_enabled          = each.value.network_interface.ip_forwarding_enabled
}

# Create Master node(s) - Linux Virtual Machine(s)
module "project_main_nodes" {
  source = "git@github.com:thanos1983/terraform//Azure/modules/LinuxVirtualMachine"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  os_disk_block = {
    name                 = each.value.linux_virtual_machine.os_disk.name
    caching              = each.value.linux_virtual_machine.os_disk.caching
    disk_size_gb         = each.value.linux_virtual_machine.os_disk.disk_size_gb
    storage_account_type = each.value.linux_virtual_machine.os_disk.storage_account_type
  }
  admin_ssh_key_blocks = [
    {
      username = var.username
      public_key = file(var.admin_ssh_key)
    }
  ]
  tags                         = var.tags
  admin_username               = var.username
  source_image_reference_block = var.source_image_reference
  resource_group_name          = module.project_resource_group.name
  size                         = each.value.linux_virtual_machine.size
  name                         = each.value.linux_virtual_machine.name
  location                     = module.project_resource_group.location
  availability_set_id          = module.project_nodes_availability_set.id
  custom_data                  = each.value.linux_virtual_machine.custom_data
  network_interface_ids = [module.project_nodes_network_interfaces[each.key].id]
}

# Ansible roles to deploy HAProxy node(s)
module "project_k8s_ansible_playbook_load_balancer" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  for_each   = local.haPoxyLoadBalancer
  playbook   = var.playbook
  replayable = var.replayable
  tags       = each.value.tags
  name       = module.project_main_nodes[each.key].public_ip_address
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
  name       = module.project_main_nodes[each.key].public_ip_address
  extra_vars = {
    domain                    = var.zone
    ansible_user              = var.username
    serviceCidr               = var.serviceCidr
    faasNamespace             = var.faasNamespace
    istioNamespace            = var.istioNamespace
    podNetworkCidr            = var.podNetworkCidr
    lb_stats_uri_path         = var.haProxyStatsUriPath
    certManagerNamespace      = var.certManagerNamespace
    lb_stats_bind_port        = var.haProxyStatsBindPort
    kubeConfigDestination     = var.kubeConfigDestination
    kube_api_bind_port        = var.kubeServerApiServerBindPort
    secretName                = var.cloudflare_secretKeyRef_name
    AZURE_NODE_RESOURCE_GROUP = module.project_resource_group.name
    secretValue               = module.projekt_cloudflare_api_token.value
    AZURE_TENANT_ID           = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID     = data.azurerm_client_config.current.subscription_id
    lb_ip_address             = module.project_nodes_public_ips["haProxyLB"].ip_address
  }
  depends_on = [
    module.project_k8s_ansible_playbook_load_balancer
  ]
}

# Applying helm istio base deployment
module "projekt_k8s_cluster_helm_istio_base_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.istio-base.wait
  name              = local.istio-base.name
  chart             = local.istio-base.chart
  values            = local.istio-base.values
  helm_version      = local.istio-base.version
  namespace         = local.istio-base.namespace
  repository        = local.istio-base.repository
  set_blocks        = local.istio-base.set_blocks
  wait_for_jobs     = local.istio-base.wait_for_jobs
  create_namespace  = local.istio-base.create_namespace
  depends_on = [
    module.project_k8s_ansible_playbook
  ]
}

# Install or upgrade the Kubernetes Gateway API CRDs
resource "terraform_data" "gateway_api_crds" {
  provisioner "local-exec" {
    command = "kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.kubernetes-gateway-api-version}/standard-install.yaml"
  }

  depends_on = [
    module.projekt_k8s_cluster_helm_istio_base_deployment
  ]
}

# Applying helm istio discovery deployment
module "projekt_k8s_cluster_helm_istio_discovery_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.istio-discovery.wait
  name              = local.istio-discovery.name
  chart             = local.istio-discovery.chart
  values            = local.istio-discovery.values
  helm_version      = local.istio-discovery.version
  namespace         = local.istio-discovery.namespace
  repository        = local.istio-discovery.repository
  set_blocks        = local.istio-discovery.set_blocks
  wait_for_jobs     = local.istio-discovery.wait_for_jobs
  create_namespace  = local.istio-discovery.create_namespace
  depends_on = [
    terraform_data.gateway_api_crds
  ]
}

# Applying helm istio cni deployment
module "projekt_k8s_cluster_helm_istio_cni_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.istio-cni.wait
  name              = local.istio-cni.name
  chart             = local.istio-cni.chart
  values            = local.istio-cni.values
  helm_version      = local.istio-cni.version
  namespace         = local.istio-cni.namespace
  repository        = local.istio-cni.repository
  set_blocks        = local.istio-cni.set_blocks
  wait_for_jobs     = local.istio-cni.wait_for_jobs
  create_namespace  = local.istio-cni.create_namespace
  depends_on = [
    module.projekt_k8s_cluster_helm_istio_discovery_deployment
  ]
}

# Applying helm istio ztunnel deployment
module "projekt_k8s_cluster_helm_istio_ztunnel_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.istio-ztunnel.wait
  name              = local.istio-ztunnel.name
  chart             = local.istio-ztunnel.chart
  values            = local.istio-ztunnel.values
  helm_version      = local.istio-ztunnel.version
  namespace         = local.istio-ztunnel.namespace
  repository        = local.istio-ztunnel.repository
  set_blocks        = local.istio-ztunnel.set_blocks
  wait_for_jobs     = local.istio-ztunnel.wait_for_jobs
  create_namespace  = local.istio-ztunnel.create_namespace
  depends_on = [
    module.projekt_k8s_cluster_helm_istio_cni_deployment
  ]
}

# Applying helm istio gateway deployment
module "projekt_k8s_cluster_helm_istio_gateway_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.istio-gateway.wait
  name              = local.istio-gateway.name
  chart             = local.istio-gateway.chart
  values            = local.istio-gateway.values
  helm_version      = local.istio-gateway.version
  namespace         = local.istio-gateway.namespace
  repository        = local.istio-gateway.repository
  set_blocks        = local.istio-gateway.set_blocks
  wait_for_jobs     = local.istio-gateway.wait_for_jobs
  create_namespace  = local.istio-gateway.create_namespace
  depends_on = [
    module.projekt_k8s_cluster_helm_istio_ztunnel_deployment
  ]
}

# Applying all helm module(s) deployment(s)
module "projekt_k8s_cluster_helm_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  for_each          = local.helm_deployment
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
module "project_k8s_ansible_playbook_cert_manager_issuer" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  tags = ["k8sAnsible"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_main_nodes["master01"].public_ip_address
  extra_vars = {
    domain          = var.zone
    ansible_user    = var.username
    issuerNamespace = var.istioNamespace
    acme_email      = var.CLOUDFLARE_EMAIL
    secretKeyRef    = var.cloudflare_secretKeyRef_key
    secretName      = var.cloudflare_secretKeyRef_name
  }
  depends_on = [
    module.projekt_k8s_cluster_helm_deployment
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
