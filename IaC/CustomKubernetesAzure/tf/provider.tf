provider "cloudflare" {
  email   = local.decoded_vault_yaml.cloudflare.email
  api_key = local.decoded_vault_yaml.cloudflare.api_key
}

provider "azurerm" {
  features {
    resource_group {
      # Due to PVC of Kubescape we can remove them.
      # prevent_deletion_if_contains_resources = true
    }
  }
  subscription_id = var.ARM_SUBSCRIPTION_ID # set as env variable
}

provider "helm" {
  kubernetes = {
    config_path = local.kubeConfigDestination
  }
}

provider "external" {}
provider "ansible" {}
provider "remote" {}
provider "local" {}
