terraform {
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "1.5.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.10.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.29.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.4.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = "0.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }
  }
  backend "azurerm" {}
  required_version = ">= 0.18.0"
}
