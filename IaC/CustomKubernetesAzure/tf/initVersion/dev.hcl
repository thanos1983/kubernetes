container_name       = "hybrid-arc-k8s"
key                  = "terraform.tfstate"
resource_group_name  = "rg-hybrid-arc-iac"
storage_account_name = "saiacprojekthybridarc"
subscription_id      = var.ARM_SUBSCRIPTION_ID_STATE_FILE
