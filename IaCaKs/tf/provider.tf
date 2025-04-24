provider "cloudflare" {
  email = var.CLOUDFLARE_EMAIL # set as env variable
  api_key = var.CLOUDFLARE_API_KEY # set as env variable
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = var.ARM_SUBSCRIPTION_ID # set as env variable
}

provider "kubectl" {
  load_config_file  = var.load_config_file
  apply_retry_count = var.apply_retry_count
  host              = module.kitn_projekt_aks_cluster.kube_admin_config[0].host
  client_key = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_key)
  client_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = module.kitn_projekt_aks_cluster.kube_admin_config[0].host
    client_key = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_key)
    client_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_certificate)
    cluster_ca_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host = module.kitn_projekt_aks_cluster.kube_admin_config[0].host
  client_key = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_key)
  client_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].client_certificate)
  cluster_ca_certificate = base64decode(module.kitn_projekt_aks_cluster.kube_admin_config[0].cluster_ca_certificate)
}