terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.3"
    }
  }
  backend "azurerm" {}
  required_version = ">= 0.18.0"
}