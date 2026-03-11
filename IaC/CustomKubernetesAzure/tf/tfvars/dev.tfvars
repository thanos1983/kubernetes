location                           = "North Europe" # "Sweden Central"
environment                        = "dev"
resource_group_name                = "dev_k8s_kubeadm"
ingressReplicaCount                = 2
lokiNumberOfReplicas               = 3
ollamaNumberOfReplicas             = 1
headlampReplicaCount               = 1
network_security_group_name        = "k8s-dev-nsg01"
platform_fault_domain_count        = 2
platform_update_domain_count       = 3
master_nodes_availability_set_name = "masterNodesDevAvailabilitySet"

tags = {
  containerApps = "true"
  createdWith   = "Terraform"
  environment   = "prod"
  team          = "containers"
}

managedDisks = {
  prometheus = {
    disk_size_gb            = "10"
    create_option           = "Empty"
    name                    = "prometheus"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "azuredisk-prometheus"
    persistent_volume_claim = "prometheus-server"
    storage_class_name      = "azuredisk-prometheus"
  }
  grafana = {
    disk_size_gb            = "10"
    create_option           = "Empty"
    name                    = "grafana"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "azuredisk-grafana"
    persistent_volume_claim = "grafana"
    storage_class_name      = "azuredisk-grafana"
  }
  loki-backend-0 = {
    disk_size_gb            = "2"
    name                    = "loki-backend-0"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-backend-0"
    persistent_volume_claim = "data-loki-backend-0"
    storage_class_name      = "azuredisk-loki-backend0"
  }
  loki-backend-1 = {
    disk_size_gb            = "2"
    name                    = "loki-backend-1"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-backend-1"
    persistent_volume_claim = "data-loki-backend-1"
    storage_class_name      = "azuredisk-loki-backend1"
  }
  loki-backend-2 = {
    disk_size_gb            = "2"
    name                    = "loki-backend-2"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-backend-2"
    persistent_volume_claim = "data-loki-backend-2"
    storage_class_name      = "azuredisk-loki-backend2"
  }
  loki-write-0 = {
    disk_size_gb            = "2"
    name                    = "loki-write-0"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-write-0"
    persistent_volume_claim = "data-loki-write-0"
    storage_class_name      = "azuredisk-loki-write0"
  }
  loki-write-1 = {
    disk_size_gb            = "2"
    name                    = "loki-write-1"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-write-1"
    persistent_volume_claim = "data-loki-write-1"
    storage_class_name      = "azuredisk-loki-write1"
  }
  loki-write-2 = {
    disk_size_gb            = "2"
    name                    = "loki-write-2"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "data-loki-write-2"
    persistent_volume_claim = "data-loki-write-2"
    storage_class_name      = "azuredisk-loki-write2"
  }
  ollama = {
    disk_size_gb            = "10"
    name                    = "open-webui-ollama"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "open-webui-ollama"
    persistent_volume_claim = "open-webui-ollama"
    storage_class_name      = "azuredisk-ollama"
  }
  openwebui = {
    disk_size_gb            = "2"
    name                    = "open-webui"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "open-webui"
    persistent_volume_claim = "open-webui"
    storage_class_name      = "azuredisk-openwebui"
  }
  openwebui-pipelines = {
    disk_size_gb            = "2"
    name                    = "open-webui-pipelines"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "open-webui-pipelines"
    persistent_volume_claim = "open-webui-pipelines"
    storage_class_name      = "azuredisk-openwebui-pipelines"
  }
  kubescape-storage = {
    disk_size_gb            = "10"
    name                    = "kubescape-storage"
    create_option           = "Empty"
    storage_account_type    = "Standard_LRS"
    persistent_volume_name  = "kubescape-storage"
    persistent_volume_claim = "kubescape-storage"
    storage_class_name      = "kubescape-storage-sc"
  }
}
