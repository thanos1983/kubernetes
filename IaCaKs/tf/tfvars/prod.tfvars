sku_tier            = "Standard"
location            = "West Europe"
environment         = "prod"
acme_server         = "https://acme-v02.api.letsencrypt.org/directory"
issuer_name         = "letsencrypt-prod"
secret_key_ref      = "letsencrypt-prod"
storage_account     = "demoprodaks"
aks_cluster_name    = "demo_test_aks_cluster"
resource_group_name = "demoProdRG"
ingressReplicaCount = 2
qdrant_replicaCount = 3
kubernetes_version  = "1.33.3"

storage_account_container_names = {
  loki_container_chunk = "loki-chunk"
  loki_container_ruler = "loki-ruler"
  tempo_container_name = "tempo-traces"
}

default_node_pool_block = {
  name                        = "aks"
  vm_size                     = "Standard_D4s_v3"
  node_count                  = 3
  temporary_name_for_rotation = "aksrotation"
  upgrade_settings_block = {
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
    max_surge                     = "10%"
  }
}

tags = {
  createdWith = "Terraform"
  environment = "prod"
  purpose     = "devops"
  team        = "demo"
  vendor      = "test"
}
