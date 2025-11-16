sku_tier            = "Standard"
location            = "West Europe"
environment         = "test"
acme_server         = "https://acme-staging-v02.api.letsencrypt.org/directory"
issuer_name         = "letsencrypt-stage"
secret_key_ref      = "letsencrypt-stage"
storage_account     = "stdemotestaks"
aks_cluster_name    = "demo_test_aks_cluster"
kubernetes_version  = "1.33.3"
resource_group_name = "demoTestRG"
ingressReplicaCount = 1
qdrant_replicaCount = 1

storage_account_container_names = {
  loki_container_chunk = "loki-chunk"
  loki_container_ruler = "loki-ruler"
  tempo_container_name = "tempo-traces"
}

default_node_pool_block = {
  name                        = "aks"
  vm_size                     = "Standard_A4_v2"
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
  environment = "test"
  purpose     = "devops"
  team        = "demo"
  vendor      = "test"
}
