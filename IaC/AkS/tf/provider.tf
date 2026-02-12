provider "ansible" {}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = var.ARM_SUBSCRIPTION_ID # set as env variable
}

provider "cloudflare" {
  email   = local.decoded_vault_yaml.cloudflare.email
  api_key = local.decoded_vault_yaml.cloudflare.api_key
}

provider "kubectl" {
  load_config_file       = var.load_config_file
  apply_retry_count      = var.apply_retry_count
  host                   = module.aks_project_aks_cluster.kube_admin_config[0].host
  client_key             = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_key)
  client_certificate     = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
}

provider "kubernetes" {
  host                   = module.aks_project_aks_cluster.kube_admin_config[0].host
  client_key             = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_key)
  client_certificate     = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes = {
    host                   = module.aks_project_aks_cluster.kube_admin_config[0].host
    client_key             = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_key)
    client_certificate     = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].client_certificate)
    cluster_ca_certificate = base64decode(module.aks_project_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
  }
}
