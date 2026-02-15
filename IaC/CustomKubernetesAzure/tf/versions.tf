terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.7.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.60.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.17.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.2"
    }
  }
  backend "azurerm" {}
  required_version = ">= 0.18.0"
}
