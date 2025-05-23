terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.29.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.4.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
  backend "azurerm" {}
  required_version = ">= 0.18.0"
}
