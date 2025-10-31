sku_tier                  = "Standard"
location                  = "West Europe"
environment               = "prod"
aks_cluster_name          = "demo_test_aks_cluster"
resource_group_name       = "demoProdRG"
storage_account           = "demoprodaks"
# dns_label                 = "prodaks"
ingressReplicaCount       = 2
qdrant_replicaCount       = 3
kubernetes_version        = "1.33.3"
# grafana_secret_key_ref    = "grafana-cert"
# prometheus_secret_key_ref = "prometheus-cert"
# secret_key_ref            = "letsencrypt-prod"
# cluster_issuer_name       = "letsencrypt-prod"
# acme_server               = "https://acme-v02.api.letsencrypt.org/directory"

default_node_pool_blocks = [
  {
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
]

tags = {
  createdWith = "Terraform"
  environment = "prod"
  purpose     = "devops"
  team        = "demo"
  vendor      = "test"
}