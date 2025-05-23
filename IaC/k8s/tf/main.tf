# Create Resource Group
module "project_resource_group" {
  source              = "git@github.com:oneNNIT/internal-azure//tf/modules/ResourceGroup"
  tags                = var.tags
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create necessary Azure Disk(s)
module "project_azure_disks" {
  source               = "git@github.com:oneNNIT/internal-azure//tf/modules/ManagedDisk"
  for_each = toset(var.azure_disks)
  name                 = each.key
  tags                 = var.tags
  disk_size_gb         = var.disk_size_gb
  create_option        = var.create_option
  storage_account_type = var.storage_account_type
  resource_group_name  = module.project_resource_group.name
  location             = module.project_resource_group.location
}

# Create necessary AzureAD Application
module "project_application_azure_disks" {
  source       = "git@github.com:oneNNIT/internal-azure//tf/modules/Application"
  display_name = "azureDiskCsiDriverApplication"
  owners = [data.azuread_client_config.current.object_id]
  password_block = {
    display_name = "azureDiskCsiDriverAadClientSecret"
  }
}

# Create Service Principal for Application
module "project_application_service_principal_azure_disks" {
  source    = "git@github.com:oneNNIT/internal-azure//tf/modules/ServicePrincipal"
  owners = [data.azuread_client_config.current.object_id]
  client_id = module.project_application_azure_disks.client_id
}

# Create RBAC Assignment for the Disk Application
module "project_application_service_principal_rbac_azure_disks" {
  source                           = "git@github.com:oneNNIT/internal-azure//tf/modules/RoleAssignment"
  scope                            = data.azurerm_subscription.subscription.id
  principal_id                     = module.project_application_service_principal_azure_disks.object_id
  role_definition_name             = "Contributor"
  skip_service_principal_aad_check = true
}

# Create Cloudflare Api Token for External DNS
module "project_cloudflare_api_token" {
  source   = "git@github.com:oneNNIT/internal-azure//cloudflare/modules/ApiToken"
  status   = var.status
  policies = local.cloudflare_policies
  name     = var.cloudflare_api_token_name
}

# Create Network Security Group
module "project_network_security_group" {
  source               = "git@github.com:oneNNIT/internal-azure//tf/modules/NetworkSecurityGroup"
  tags                 = var.tags
  security_rule_blocks = local.security_rules
  name                 = var.network_security_group_name
  resource_group_name  = module.project_resource_group.name
  location             = module.project_resource_group.location
}

# Create virtual network
module "project_virtual_network" {
  source              = "git@github.com:oneNNIT/internal-azure//tf/modules/VirtualNetwork"
  tags                = var.tags
  name                = local.network.virtual_network.name
  resource_group_name = module.project_resource_group.name
  location            = module.project_resource_group.location
  address_space       = local.network.virtual_network.address_space
}

# Create Virtual Networks Subnets
module "project_virtual_network_subnet" {
  source               = "git@github.com:oneNNIT/internal-azure//tf/modules/VirtualNetworkSubNet"
  service_endpoints    = var.service_endpoints
  resource_group_name  = module.project_resource_group.name
  virtual_network_name = module.project_virtual_network.name
  name                 = local.network.virtual_network.subnet.k8s.name
  address_prefixes     = local.network.virtual_network.subnet.k8s.address_prefixes
}

# Assign Network Security Group to the Subnet
# module "project_network_security_group_association" {
#   source                    = "git@github.com:oneNNIT/internal-azure//tf/modules/SubnetNetworkSecurityGroupAssociation"
#   network_security_group_id = module.project_network_security_group.id
#   subnet_id                 = module.project_virtual_network_subnet.id
# }

# Create Availability VM Set for Master node(s)
module "project_nodes_availability_set" {
  source                       = "git@github.com:oneNNIT/internal-azure//tf/modules/AvailabilitySet"
  tags                         = var.tags
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  resource_group_name          = module.project_resource_group.name
  location                     = module.project_resource_group.location
  name                         = var.master_nodes_availability_set_name
}

# Create public IP(s) for Master Node(s)
module "project_nodes_public_ips" {
  source              = "git@github.com:oneNNIT/internal-azure//tf/modules/PublicIP"
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
module "project_knative_dns_records" {
  source   = "git@github.com:oneNNIT/internal-azure//cloudflare/modules/DnsRecord"
  for_each = local.cloudFlareTypeDnsRecord
  zone_id  = var.CLOUDFLARE_ZONE_ID
  content  = each.value.content
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
}

# Create Network Interfaces for Master node(s)
module "project_nodes_network_interfaces" {
  source = "git@github.com:oneNNIT/internal-azure//tf/modules/NetworkInterface"
  for_each = merge(local.haPoxyLoadBalancer, local.master_nodes, local.worker_nodes)
  tags   = var.tags
  name   = each.value.network_interface.name
  ip_configuration_blocks = [
    {
      public_ip_address_id          = module.project_nodes_public_ips[each.key].id
      subnet_id                     = module.project_virtual_network_subnet.id
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
  source = "git@github.com:oneNNIT/internal-azure//tf/modules/LinuxVirtualMachine"
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
  depends_on = [
    module.project_azure_disks
  ]
}

# Ansible roles to deploy HAProxy node(s)
module "project_k8s_ansible_playbook_load_balancer" {
  source     = "git@github.com:oneNNIT/internal-azure//ansible/modules/Playbook"
  playbook   = var.playbook
  replayable = var.replayable
  tags       = local.haPoxyLoadBalancer.haProxyLB.tags
  name       = module.project_main_nodes["haProxyLB"].public_ip_address
  extra_vars = {
    ansible_user = var.username
  }
}

# Extract kubernetes certificate key which is encrypted
data "external" "certs" {
  program = ["bash", "${path.module}/scripts/decodeAnsibleVaultFile.sh"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    vaultencryptedfile = local.vault_file
  }
}

# Instantiate Prime Master Node
resource "terraform_data" "prime_master_node" {
  connection {
    agent = true
    type  = "ssh"
    user  = var.username
    host  = module.project_main_nodes["master11"].public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo kubeadm init --upload-certs --control-plane-endpoint=${module.project_main_nodes["haProxyLB"].public_ip_address} --apiserver-bind-port=${var.kubeServerApiServerBindPort} --certificate-key=${data.external.certs.result.certs} --cri-socket=${var.criSocket} --pod-network-cidr=${var.podNetworkCidr} --service-cidr=${var.serviceCidr}"
    ]
  }
  depends_on = [
    module.project_k8s_ansible_playbook_load_balancer
  ]
}

# Extract kube config file from Prime Master Node
data "remote_file" "kube_config" {
  conn {
    sudo  = true
    agent = true
    user  = var.username
    host  = module.project_main_nodes["master11"].public_ip_address
  }

  path = var.kubeConfig

  depends_on = [
    terraform_data.prime_master_node
  ]
}

# Store locally kube config file
module "project_k8s_local_sensitive_file_kube_config" {
  source   = "git@github.com:oneNNIT/internal-azure//tf/modules/LocalSensitiveFile"
  content  = data.remote_file.kube_config.content
  filename = local.kubeConfigDestination
}

# Create Bootstrap Token
data "external" "token" {
  program = ["bash", "${path.module}/scripts/bootstrapToken.sh"]

  query = {
    # arbitrary map from strings to strings, passed
    # to the external program as the data query.
    kubeconfig = local.kubeConfigDestination
  }

  depends_on = [
    module.project_k8s_local_sensitive_file_kube_config
  ]
}

# Instantiate Secondary Master Nodes
resource "terraform_data" "secondary_master_nodes" {
  for_each = setsubtract(keys(local.master_nodes), ["master11"])
  connection {
    agent = true
    type  = "ssh"
    user  = var.username
    host  = module.project_main_nodes[each.key].public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ${trimspace(data.external.token.result.token)} --certificate-key=${data.external.certs.result.certs} --cri-socket=${var.criSocket} --control-plane",
    ]
  }
}

# Instantiate Worker Nodes
resource "terraform_data" "worker_nodes" {
  for_each = local.worker_nodes
  connection {
    agent = true
    type  = "ssh"
    user  = var.username
    host  = module.project_main_nodes[each.key].public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ${trimspace(data.external.token.result.token)} --certificate-key=${data.external.certs.result.certs} --cri-socket=${var.criSocket}"
    ]
  }

  provisioner "local-exec" {
    command = "kubectl label node ${lower(each.value.linux_virtual_machine.name)} kubernetes.io/role=worker --kubeconfig ${local.kubeConfigDestination}"
  }
}

# Creating Prerequisites for Azure Disk CSI driver
module "project_k8s_ansible_playbook_prerequisites_azure_disk_csi_driver" {
  source     = "git@github.com:oneNNIT/internal-azure//ansible/modules/Playbook"
  tags = ["k8sPrerequisites"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_main_nodes["master11"].public_ip_address
  extra_vars = {
    faasNamespace                = var.faasNamespace
    azureDiskCsiDriverNamespace  = var.kubeNamespace
    istioNamespace               = var.istioNamespace
    monitoringNamespace          = var.monitoringNamespace
    certManagerNamespace         = var.certManagerNamespace
    secretNameAzureDiskCsiDriver = var.cloudConfigSecretName
    kubeConfigDestination        = local.kubeConfigDestination
    secretName                   = var.cloudflare_secretKeyRef_name
    secretValue                  = module.project_cloudflare_api_token.value
    azureJsonSecretValue = templatefile("${path.module}/azureDiskCsiDriver/azure.json.tftpl", {
      RESOURCE-GROUP              = module.project_resource_group.name
      SECURITYGROUPRESOURCE-GROUP = module.project_resource_group.name
      VNET-NAME                   = module.project_virtual_network.name
      LOCATION                    = module.project_resource_group.location
      SUBNET-NAME                 = module.project_virtual_network_subnet.name
      SECURITYGROUP-NAME          = module.project_network_security_group.name
      TENANT-ID                   = data.azurerm_client_config.current.tenant_id
      AADCLIENT-ID                = module.project_application_azure_disks.client_id
      SUBSCRIPTION-ID             = data.azurerm_client_config.current.subscription_id
      VNETRESOURCE-GROUP          = module.project_virtual_network.resource_group_name
      AADCLIENT-SECRET            = tolist(module.project_application_azure_disks.password).0.value
    })
  }
  depends_on = [
    module.project_k8s_local_sensitive_file_kube_config
  ]
}

module "project_k8s_cluster_helm_fundamental_charts_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
  for_each          = local.helm_prime_packages
  force_update      = var.force_update
  wait              = each.value.wait
  name              = each.value.name
  chart             = each.value.chart
  values            = each.value.values
  helm_version      = each.value.version
  namespace         = each.value.namespace
  repository        = each.value.repository
  set_blocks        = each.value.set_blocks
  dependency_update = var.dependency_update
  wait_for_jobs     = each.value.wait_for_jobs
  create_namespace  = each.value.create_namespace
  depends_on = [
    module.project_k8s_ansible_playbook_prerequisites_azure_disk_csi_driver
  ]
}

# Deploying Azure Disk CSI driver
module "project_k8s_cluster_helm_azure_disk_csi_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
  force_update      = var.force_update
  dependency_update = var.dependency_update
  wait              = local.azure_csi_driver.wait
  name              = local.azure_csi_driver.name
  chart             = local.azure_csi_driver.chart
  values            = local.azure_csi_driver.values
  helm_version      = local.azure_csi_driver.version
  namespace         = local.azure_csi_driver.namespace
  repository        = local.azure_csi_driver.repository
  set_blocks        = local.azure_csi_driver.set_blocks
  wait_for_jobs     = local.azure_csi_driver.wait_for_jobs
  create_namespace  = local.azure_csi_driver.create_namespace
  depends_on = [
    module.project_k8s_ansible_playbook_prerequisites_azure_disk_csi_driver
  ]
}

# Creating required storage configurations for Azure Disk CSI driver
module "project_k8s_ansible_playbook_azure_disk_csi_driver" {
  source     = "git@github.com:oneNNIT/internal-azure//ansible/modules/Playbook"
  tags = ["k8sStorage"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_main_nodes["master11"].public_ip_address
  extra_vars = {
    skuName                                     = var.skuName
    storageSizeGrafana                          = var.storageSizeGrafana
    storageClassGrafana                         = var.storageClassGrafana
    persistentVolumeClaimNamespace              = var.monitoringNamespace
    storageClassPrometheus                      = var.storageClassPrometheus
    kubeConfigDestination                       = local.kubeConfigDestination
    persistentVolumeGrafana                     = var.persistentVolumeGrafana
    storageSizePrometheusServer                 = var.storageSizePrometheusServer
    grafanaPersistentVolumeClaim                = var.grafanaPersistentVolumeClaim
    persistentVolumePrometheusServer            = var.persistentVolumePrometheusServer
    storageSizePrometheusAlertManager           = var.storageSizePrometheusAlertManager
    prometheusServerPersistentVolumeClaim       = var.prometheusServerPersistentVolumeClaim
    persistentVolumePrometheusAlertManager      = var.persistentVolumePrometheusAlertManager
    prometheusAlertManagerPersistentVolumeClaim = var.prometheusAlertManagerPersistentVolumeClaim
    volumeHandle                                = module.project_azure_disks["prometheus_disk"].id
  }
  depends_on = [
    module.project_main_nodes,
    module.project_k8s_cluster_helm_azure_disk_csi_deployment
  ]
}

# Applying helm istio base deployment
module "project_k8s_cluster_helm_istio_base_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
    module.project_k8s_cluster_helm_azure_disk_csi_deployment
  ]
}

# Install or upgrade the Kubernetes Gateway API CRDs
resource "terraform_data" "gateway_api_crds" {
  provisioner "local-exec" {
    command = "kubectl get crd gateways.gateway.networking.k8s.io --kubeconfig ${local.kubeConfigDestination} &> /dev/null"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.kubernetes-gateway-api-version}/standard-install.yaml --kubeconfig ${local.kubeConfigDestination}"
  }

  depends_on = [
    module.project_k8s_cluster_helm_istio_base_deployment
  ]
}

# Applying helm istio discovery deployment
module "project_k8s_cluster_helm_istio_discovery_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
module "project_k8s_cluster_helm_istio_cni_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
    module.project_k8s_cluster_helm_istio_discovery_deployment
  ]
}

# Applying helm istio ztunnel deployment
module "project_k8s_cluster_helm_istio_ztunnel_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
    module.project_k8s_cluster_helm_istio_cni_deployment
  ]
}

# Applying helm istio gateway deployment
module "project_k8s_cluster_helm_istio_gateway_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
    module.project_k8s_cluster_helm_istio_ztunnel_deployment
  ]
}

# Applying all helm module(s) deployment(s)
module "project_k8s_cluster_helm_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
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
    module.project_k8s_cluster_helm_azure_disk_csi_deployment
  ]
}

# Applying last helm module(s) deployment(s)
module "project_k8s_cluster_post_helm_deployment" {
  source            = "git@github.com:oneNNIT/internal-azure//helm/modules/Release"
  for_each          = local.post_helm_deployment
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
    module.project_k8s_cluster_helm_deployment
  ]
}

# Create desired CertManager Cluster Issuer(s)
module "project_k8s_ansible_playbook_cert_manager_issuer" {
  source     = "git@github.com:oneNNIT/internal-azure//ansible/modules/Playbook"
  tags = ["k8sIssuer"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_main_nodes["master11"].public_ip_address
  extra_vars = {
    domain                = var.zone
    ansible_user          = var.username
    issuerNamespace       = var.istioNamespace
    acme_email            = var.CLOUDFLARE_EMAIL
    issuer_name_prod      = var.issuer_name_prod
    issuer_name_stage     = var.issuer_name_stage
    kubeConfigDestination = local.kubeConfigDestination
    secretKeyRef          = var.cloudflare_secretKeyRef_key
    secretName            = var.cloudflare_secretKeyRef_name
  }
  depends_on = [
    module.project_k8s_cluster_helm_deployment
  ]
}

# Create GW Routes
module "project_k8s_istio_gw_routes" {
  source     = "git@github.com:oneNNIT/internal-azure//ansible/modules/Playbook"
  for_each   = local.istioGateway
  tags = ["IstioGWRoutes"]
  playbook   = var.playbook
  replayable = var.replayable
  name       = module.project_main_nodes["master11"].public_ip_address
  extra_vars = {
    hosts                                        = each.value.hosts
    component                                    = each.value.component
    namespace                                    = each.value.namespace
    secretName                                   = each.value.secretName
    commonName                                   = each.value.commonName
    kubernetesVersion                            = var.kubernetes_version
    gatewayName                                  = each.value.gatewayName
    gatewayTlsMode                               = each.value.gatewayTlsMode
    gatewaySelector                              = each.value.gatewaySelector
    kubeConfigDestination                        = local.kubeConfigDestination
    virtualServiceName                           = each.value.virtualServiceName
    certificateNamespace                         = each.value.certificateNamespace
    virtualServiceGateways                       = each.value.virtualServiceGateways
    certificateIssuerRefName                     = each.value.certificateIssuerRefName
    virtualServiceHttpMatchUriPrefix             = each.value.virtualServiceHttpMatchUriPrefix
    virtualServiceHttpRouteDestinationHost       = each.value.virtualServiceHttpRouteDestinationHost
    virtualServiceHttpRouteDestinationPortNumber = each.value.virtualServiceHttpRouteDestinationPortNumber
  }
  depends_on = [
    module.project_k8s_cluster_helm_deployment
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
