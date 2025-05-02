terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.50.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.3.0"
    }
  }
  backend "azurerm" {}
  required_version = ">= 0.18.0"
}
