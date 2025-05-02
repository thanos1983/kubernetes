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
  subscription_id = var.ARM_SUBSCRIPTION_ID # set as env variable
}

provider "helm" {
  kubernetes {
    config_path = var.kubeConfigDestination
  }
}

provider "kubernetes" {
  config_path = var.kubeConfigDestination
}

provider "hcloud" {
  token = var.HETZNER_API_TOKEN
}
