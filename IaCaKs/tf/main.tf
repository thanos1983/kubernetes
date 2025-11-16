# Create Azure Active Directory Group
module "aks_project_active_directory_group" {
  source             = "git@github.com:thanos1983/terraform//Azure/modules/ActiveDirectoryGroup"
  for_each           = merge(local.aks_active_directory_groups, local.aks_active_directory_admin_group)
  security_enabled   = var.security_enabled
  assignable_to_role = var.assignable_to_role
  description        = each.value.description
  display_name       = each.value.display_name
  members            = each.value.members
  owners             = each.value.owners
}

# Role Assignment for Active Directory Group to gain access to AKS cluster
module "aks_project_subscription_identity_ad_group_assignment" {
  source               = "git@github.com:thanos1983/terraform//Azure/modules/RoleAssignment"
  for_each             = merge(local.aks_active_directory_groups, local.aks_active_directory_admin_group)
  role_definition_name = var.aksRoleAssignment
  scope                = data.azurerm_subscription.subscription.id
  principal_id         = module.aks_project_active_directory_group[each.key].object_id
}

# Create Resource Group
module "aks_project_resource_group" {
  source              = "git@github.com:thanos1983/terraform//Azure/modules/ResourceGroup"
  tags                = var.tags
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create virtual network
module "aks_project_virtual_network" {
  source              = "git@github.com:thanos1983/terraform.git//Azure/modules/VirtualNetwork"
  tags                = var.tags
  name                = local.network.virtual_network.name
  resource_group_name = module.aks_project_resource_group.name
  address_space       = local.network.virtual_network.address_space
  location            = module.aks_project_resource_group.location
}

# Create Virtual Networks Subnets
module "aks_project_virtual_network_subNet" {
  source               = "git@github.com:thanos1983/terraform.git//Azure/modules/VirtualNetworkSubNet"
  for_each             = local.network.virtual_network.subnets
  name                 = each.value.name
  service_endpoints    = var.service_endpoints
  address_prefixes     = each.value.address_prefixes
  resource_group_name  = module.aks_project_resource_group.name
  virtual_network_name = module.aks_project_virtual_network.name
}

# Create Cloudflare Api Token for External DNS
module "aks_project_cloudflare_api_token" {
  source   = "git@github.com:thanos1983/terraform//Cloudflare/modules/ApiToken"
  status   = var.status
  policies = local.cloudflare_policies
  name     = var.cloudflare_api_token_name
}

# Create AKS cluster
module "aks_project_aks_cluster" {
  source             = "git@github.com:thanos1983/terraform//Azure/modules/KubernetesCluster"
  tags               = var.tags
  sku_tier           = var.sku_tier
  name               = var.aks_cluster_name
  kubernetes_version = var.kubernetes_version
  default_node_pool_block = {
    name                        = var.default_node_pool_block.name
    vm_size                     = var.default_node_pool_block.vm_size
    node_count                  = var.default_node_pool_block.node_count
    vnet_subnet_id              = module.aks_project_virtual_network_subNet["aks"].id
    temporary_name_for_rotation = var.default_node_pool_block.temporary_name_for_rotation
    upgrade_settings_block = {
      max_surge                     = var.default_node_pool_block.upgrade_settings_block.max_surge
      drain_timeout_in_minutes      = var.default_node_pool_block.upgrade_settings_block.drain_timeout_in_minutes
      node_soak_duration_in_minutes = var.default_node_pool_block.upgrade_settings_block.node_soak_duration_in_minutes
    }
  }
  role_definition_names     = var.aks_role_definition_names
  open_service_mesh_enabled = var.open_service_mesh_enabled
  dns_prefix                = module.aks_project_resource_group.name
  resource_group_name       = module.aks_project_resource_group.name
  location                  = module.aks_project_resource_group.location
  network_profile_block = {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
  }
  azure_active_directory_role_based_access_control_block = {
    managed                = var.managed
    azure_rbac_enabled     = var.azure_rbac_enabled
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [module.aks_project_active_directory_group["admin-group"].object_id]
  }
}

# Download kubeconfig file to local directory
module "aks_project_aks_cluster_kubeconfig" {
  source               = "git@github.com:thanos1983/terraform//TerraformSharedModules/modules/LocalSensitiveFile"
  file_permission      = var.file_permission
  filename             = local.kube_config_path
  directory_permission = var.directory_permission
  content              = module.aks_project_aks_cluster.kube_config_raw
}

# Assign RBAC subscription level role to the deployment user
module "aks_project_subscription_identity_assignment" {
  source               = "git@github.com:thanos1983/terraform//Azure/modules/RoleAssignment"
  count                = length(var.user_role_definition_names)
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = var.user_role_definition_names[count.index]
  principal_id         = data.azurerm_client_config.current.object_id
}

# Create public IP(s)
module "aks_project_public_ips" {
  source              = "git@github.com:thanos1983/terraform//Azure/modules/PublicIP"
  for_each            = local.public_ips
  tags                = var.tags
  sku                 = each.value.sku
  name                = each.value.name
  allocation_method   = each.value.allocation_method
  location            = module.aks_project_resource_group.location
  resource_group_name = module.aks_project_aks_cluster.node_resource_group
}

# Create Storage Account
module "aks_project_storage_account" {
  source = "git@github.com:thanos1983/terraform.git//Azure/modules/StorageAccount"
  tags   = var.tags
  name   = var.storage_account
  public_network_access_enabled = var.public_network_access_enabled
  resource_group_name           = module.aks_project_resource_group.name
  location                      = module.aks_project_resource_group.location
}

# Create Storage Account Network Rules
module "aks_project_storage_account_network_rules" {
  source                     = "git@github.com:thanos1983/terraform.git//Azure/modules/StorageAccountNetworkRules"
  bypass                     = var.bypass
  default_action             = var.default_action
  storage_account_id         = module.aks_project_storage_account.id
  virtual_network_subnet_ids = [module.aks_project_virtual_network_subNet["aks"].id]
}

# Create RBAC role for AKS cluster
module "aks_project_rbac_identity_assignment" {
  source               = "git@github.com:thanos1983/terraform//Azure/modules/RoleAssignment"
  role_definition_name = var.role_definition_name
  scope                = module.aks_project_storage_account.id
  principal_id         = module.aks_project_aks_cluster.identity[0].principal_id
}

# Create Storage Account Container
module "aks_project_storage_account_container" {
  source             = "git@github.com:thanos1983/terraform.git//Azure/modules/StorageContainer"
  for_each           = tomap(var.storage_account_container_names)
  name               = each.value
  storage_account_id = module.aks_project_storage_account.id
}

# Create DNS record for Knative domain(s)
module "aks_project_knative_dns_records" {
  source   = "git@github.com:thanos1983/terraform//Cloudflare/modules/DnsRecord"
  for_each = local.cloudFlareTypeDnsRecord
  zone_id  = var.CLOUDFLARE_ZONE_ID
  content  = each.value.content
  name     = each.value.name
  type     = each.value.type
  ttl      = each.value.ttl
}

# Create all needed NameSpace(s)
module "aks_project_create_namespaces" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  for_each   = local.nameSpacesToCreate
  playbook   = var.playbook
  replayable = var.replayable
  tags       = ["namespace"]
  name       = var.ansible_hostname
  extra_vars = {
    ansible_hostname   = var.ansible_hostname
    kubeConfigPath     = var.kubeConfigFilename
    ansible_connection = var.ansible_connection
    namespaceName      = each.value.metadata.name
    istioInjection     = each.value.metadata.labels.istio-injection
    host               = module.aks_project_aks_cluster.kube_admin_config[0].host
    client_key         = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_key)
    client_cert        = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_certificate)
    ca_cert            = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
  }
}

# Create all roles bindings for the needed role(s)
module "aks_project_create_namespaces_roles_binding" {
  source   = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubernetesRoleBindingV1"
  for_each = local.aks_active_directory_groups
  metadata_block = {
    name      = "${each.value.namespaceRoles.metadata_block.name}-binding"
    namespace = each.key
  }
  role_ref_block = {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = each.value.namespaceRoles.metadata_block.name
  }
  subject_blocks = [
    {
      kind      = "Group"
      namespace = each.key
      name      = module.aks_project_active_directory_group[each.key].object_id
    }
  ]
  depends_on = [
    module.aks_project_create_namespaces
  ]
}

# Create kubernetes secret for DNS vendor
module "aks_project_cloudflare_k8s_dns_secret" {
  source = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubernetesSecretV1"
  metadata_block = {
    name      = var.cloudflare_secretKeyRef_name
    namespace = local.helm_deployment_dependencies.cert-manager.namespace
  }
  data = {
    (var.cloudflare_secretKeyRef_key) = module.aks_project_cloudflare_api_token.value
  }
  depends_on = [
    module.aks_project_create_namespaces
  ]
}

# Create kubernetes secret for helm Tempo chart
module "aks_project_cloudflare_k8s_tempo_traces_stg_secret" {
  source = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubernetesSecretV1"
  metadata_block = {
    name      = var.tempo_traces_stg_key
    namespace = var.monitoring_namespace
  }
  data = {
    (var.tempo_traces_key) = module.aks_project_storage_account.primary_access_key
  }
  depends_on = [
    module.aks_project_create_namespaces
  ]
}

# Applying all helm module(s) deployment(s)
module "aks_project_aks_cluster_helm_deployment_dependencies" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  for_each          = local.helm_deployment_dependencies
  set               = each.value.set
  name              = each.value.name
  chart             = each.value.chart
  force_update      = var.force_update
  values            = each.value.values
  helm_version      = each.value.version
  namespace         = each.value.namespace
  dependency_update = var.dependency_update
  repository        = each.value.repository
  wait_for_jobs     = each.value.wait_for_jobs
  create_namespace  = each.value.create_namespace
  depends_on = [
    module.aks_project_storage_account,
    module.aks_project_cloudflare_k8s_dns_secret,
    module.aks_project_cloudflare_k8s_tempo_traces_stg_secret
  ]
}

# Create Cloudflare Secret in ISTIO GW namespace
module "aks_project_cloudflare_k8s_dns_secret_token" {
  source = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubernetesSecretV1"
  metadata_block = {
    name      = var.cloudflare_secretKeyRef_name
    namespace = var.istio_namespace
  }
  data = {
    (var.cloudflare_secretKeyRef_key) = module.aks_project_cloudflare_api_token.value
  }
  depends_on = [
    module.aks_project_aks_cluster_helm_deployment_dependencies
  ]
}

# Create Cert Manager Manifests
module "aks_project_k8s_cert_manager_issuer_manifest" {
  source    = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubectlManifest"
  for_each  = local.cert_manager_issuer_manifest
  yaml_body = each.value.yaml_body
  depends_on = [
    module.aks_project_aks_cluster_helm_deployment_dependencies
  ]
}

# Applying deployments after the dependencies have being applied
module "aks_project_aks_cluster_helm_deployment" {
  source            = "git@github.com:thanos1983/terraform//Helm/modules/Release"
  for_each          = local.helm_deployment
  set               = each.value.set
  name              = each.value.name
  chart             = each.value.chart
  force_update      = var.force_update
  values            = each.value.values
  helm_version      = each.value.version
  create_namespace  = var.create_namespace
  namespace         = each.value.namespace
  dependency_update = var.dependency_update
  repository        = each.value.repository
  wait_for_jobs     = each.value.wait_for_jobs
  depends_on = [
    module.aks_project_public_ips,
    module.aks_project_cloudflare_k8s_dns_secret,
    module.aks_project_k8s_cert_manager_issuer_manifest
  ]
}

# Download Knative Manifests
module "aks_project_download_knative_manifests" {
  source               = "git@github.com:thanos1983/terraform//TerraformSharedModules/modules/LocalFile"
  for_each             = local.knative
  content              = each.value.content
  file_permission      = var.file_permission
  filename             = each.value.filename
  directory_permission = var.directory_permission
}

# Deploy Knative Operator Manifests
module "aks_project_deploy_knative_operator_manifests" {
  source     = "git@github.com:thanos1983/terraform//Ansible/modules/Playbook"
  playbook   = var.playbook
  replayable = var.replayable
  tags       = ["knative"]
  name       = var.ansible_hostname
  extra_vars = {
    domain                   = local.knativeDomain
    kubeConfigPath           = var.kubeConfigFilename
    ansible_connection       = var.ansible_connection
    knativeServingName       = var.knativeServingName
    knativeEventingName      = var.knativeEventingName
    knativeServingNamespace  = var.knativeServingNamespace
    knativeEventingNamespace = var.knativeEventingNamespace
    knativeOperatorSrc       = local.knative.operator.filename
    knativeNetIstioSrc       = local.knative.net_istio.filename
    host                     = module.aks_project_aks_cluster.kube_admin_config[0].host
    client_key               = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_key)
    client_cert              = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_certificate)
    ca_cert                  = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
  }
  depends_on = [
    module.aks_project_download_knative_manifests,
    module.aks_project_aks_cluster_helm_deployment
  ]
}

# Create GW Routes
module "aks_project_k8s_istio_gw_routes" {
  source    = "git@github.com:thanos1983/terraform//Kubernetes/modules/KubectlManifest"
  for_each  = local.istioGateway
  yaml_body = each.value.yaml_body
  depends_on = [
    module.aks_project_aks_cluster_helm_deployment
  ]
}
