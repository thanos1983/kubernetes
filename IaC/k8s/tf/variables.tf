variable "location" {
  description = "The Azure Region where the Resource Group should exist."
  type        = string
}

variable "environment" {
  description = "Environment (stage) where the resources will be created."
  type        = string
}

variable "source_image_reference" {
  description = "A source_image_reference block as defined below."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  # not yet available for CRI-O socket
  # default = {
  #   publisher = "Canonical"
  #   offer     = "ubuntu-24_04-lts"
  #   sku       = "server"
  #   version   = "latest"
  # }
}

variable "username" {
  description = "Username to use for ssh key as defined below."
  type        = string
  default     = "tinyos"
}

variable "admin_ssh_key" {
  description = "One or more admin_ssh_key blocks as defined below."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "resource_group_name" {
  description = "The Name which should be used for this Resource Group."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type = map(any)
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "The Subscription ID which should be used."
  type        = string
}

variable "network_security_group_name" {
  description = "Specifies the name of the network security group."
  type        = string
}

variable "master_nodes_availability_set_name" {
  description = "Specifies the name of the availability set."
  type        = string
}

variable "platform_fault_domain_count" {
  description = "Specifies the number of fault domains that are used."
  type        = number
}

variable "platform_update_domain_count" {
  description = "Specifies the number of update domains that are used."
  type        = number
}

variable "protocol" {
  description = "Specifies the protocol of the end point."
  type        = string
  default     = "Http"
}

variable "kubeServerNodePortHttp" {
  description = "HTTP port for the API Server to bind to."
  type        = number
  default     = 30080
}

variable "kubeServerNodePortHttps" {
  description = "HTTPS port for the API Server to bind to."
  type        = number
  default     = 30443
}

variable "kubeServerApiServerBindPort" {
  description = "Port for the API Server to bind to."
  type        = number
  default     = 6443
}

variable "haProxyStatsBindPort" {
  description = "Port where the Stats UI will be exposed."
  type        = number
  default     = 9000
}

variable "haProxyStatsUriPath" {
  description = "Stats URI path where the stats page will be exposed."
  type        = string
  default     = "/stats"
}

variable "haProxyStatsRefreshRate" {
  description = "Stats web page refresh rate."
  type        = string
  default     = "10s"
}

variable "playbook" {
  description = "Path to ansible playbook."
  type        = string
  default     = "playbook.yml"
}

variable "replayable" {
  description = "If 'true', the playbook will be executed on every 'terraform apply' and with that, the resource will be recreated."
  type        = bool
  default     = false
}

variable "haproxy_k8s_nodes" {
  description = "The path to the file that will be created for the "
  type        = string
  default     = "roles/highAvailabilityProxy/files/haproxy.cfg"
}

variable "haproxy_keepalived_nodes" {
  description = "The path to the file that will be created for the "
  type        = string
  default     = "roles/highAvailabilityProxy/files/"
}

variable "sealed_secrets_namespace" {
  description = "The namespace where all sealed-secrets resources will be deployed."
  type        = string
  default     = "sealed-secrets"
}

variable "qdrant_replicaCount" {
  description = "Use replicaCount of Qdrant in distributed deployment mode."
  type        = number
}

variable "qdrant_namespace" {
  description = "The namespace where all monitoring resources will be deployed."
  type        = string
  default     = "qdrant"
}

variable "monitoringNamespace" {
  description = "The namespace where all monitoring resources will be deployed."
  type        = string
  default     = "monitoring"
}

variable "istioNamespace" {
  description = "The namespace in which ision core charts are to be installed."
  type        = string
  default     = "istio-system"
}

variable "MONITORING_BOOTSTRAP_PASSWORD" {
  description = "The bootstrap password for Grafana monitoring UI."
  type        = string
}

variable "cloudflare_secretKeyRef_key" {
  description = "Name of key for the DNS secret."
  type        = string
  default     = "api-token"
}

variable "cloudflare_secretKeyRef_name" {
  description = "Name of secret for the DNS secret."
  type        = string
  default     = "cloudflare-api-token"
}

variable "certManagerNamespace" {
  description = "The namespace where the Cert-Manager will be deployed."
  type        = string
  default     = "cert-manager"
}

variable "argoCdNamespace" {
  description = "The namespace where the Argo CD manifests will be deployed."
  type        = string
  default     = "argo-cd"
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed."
  type        = bool
  default     = true
}

variable "dependency_update" {
  description = "Runs helm dependency update before installing the chart."
  type        = bool
  default     = true
}

variable "zone" {
  description = "The DNS zone name which will be added."
  type        = string
  default     = "k8sdemocluster.com"
}

variable "CLOUDFLARE_EMAIL" {
  description = "A registered Cloudflare email address."
  type        = string
}

variable "CLOUDFLARE_API_KEY" {
  description = "The API key for operations."
  type        = string
}

variable "cloudflare_api_token_name" {
  description = "The Cloudflare name for the API token for the specific case."
  type        = string
  default     = "api_token_cloudflare_external_dns"
}

variable "faasNamespace" {
  description = "The name space that we will use to deploy FaaS resources."
  type        = string
  default     = "faas"
}

variable "knativeOperatorVersion" {
  description = "The version of the Knative operator to deploy."
  type        = string
  default     = "1.17.0"
}

variable "knativeNetIstioVersion" {
  description = "The version of the Knative operator to deploy."
  type        = string
  default     = "1.17.0"
}

variable "podNetworkCidr" {
  description = "Specify range of IP addresses for the pod network."
  type        = string
  default     = "10.244.0.0/16"
}

variable "serviceCidr" {
  description = "Specify range of IP addresses for the service network."
  type        = string
  default     = "10.200.0.0/16"
}

variable "ingressReplicaCount" {
  description = "How many pods should be deployed for the IngressController."
  type        = number
}

variable "accelerated_networking_enabled" {
  description = "Enable Accelerated Networking. Needed for CNI."
  type        = bool
  default     = true
}

variable "user_role_definition_names" {
  description = "The following API permissions are required in order to use the AzureAD Application resource."
  type = list(string)
  default = ["Directory Writers"]
}

variable "type" {
  description = "The connection type."
  type        = string
  default     = "ssh"
}

variable "kubernetes_version" {
  description = "Kubernetes version to install relevant packages."
  type        = string
  default     = "v1.31"
}

variable "crio_version" {
  description = "CRI-O uses the same basic project layout in OBS as Kubernetes."
  type        = string
  default     = "v1.31"
}

variable "CLOUDFLARE_ZONE_ID" {
  description = "Zone ID (can be found on the UI)."
  type        = string
}

variable "status" {
  description = "Status of the token."
  type        = string
  default     = "active"
}

variable "ttl" {
  description = "Time To Live (TTL) of the DNS record in seconds."
  type        = number
  default     = 1
}

variable "reflection-allowed-namespaces" {
  description = "Control the namespaces we want to replicate a Secret(s) of the reflector. Add more by separating them by coma."
  type        = string
  default     = "arc-dev,arc-sit,arc-uat,arc-prod"
}

variable "kubernetes-gateway-api-version" {
  description = "Kubernetes Gateway API version deployment."
  type        = string
  default     = "v1.3.0"
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled?"
  type        = bool
  default     = false
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet."
  type = list(string)
  default = ["Microsoft.Storage"]
}

variable "create_option" {
  description = "The method to use when creating the managed disk."
  type        = string
  default     = "Empty"
}

variable "storage_account_type" {
  description = "The type of storage to use for the managed disk."
  type        = string
  default     = "Premium_LRS"
  # default     = "PremiumV2_LRS"
}

variable "disk_size_gb" {
  description = "Specifies the size of the managed disk to create in gigabytes."
  type        = string
  default     = "30"
}

variable "skuName" {
  description = "Azure Disks storage account type (alias: storageAccountType)"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "azure_disks" {
  description = "Specifies the configurations of the Managed Disk(s)."
  type = list(string)
  default = ["prometheus_disk"]
}

variable "kubeNamespace" {
  description = "The namespace for objects created by the Kubernetes system."
  type        = string
  default     = "kube-system"
}

variable "cloudConfigSecretName" {
  description = "Cloud config secret name."
  type        = string
  default     = "azure-cloud-provider"
}

variable "criSocket" {
  description = "Path to the CRI socket to connect."
  type        = string
  default     = "unix:///var/run/crio/crio.sock"
}

variable "kubeConfig" {
  description = "The kubeconfig file to use when talking to the cluster."
  type        = string
  default     = "/etc/kubernetes/admin.conf"
}

variable "storageClassPrometheus" {
  description = "The name of a StorageClass for Prometheus Monitoring."
  type        = string
  default     = "azuredisk-prometheus"
}

variable "storageClassGrafana" {
  description = "The name of a StorageClass for Grafana Visualizer."
  type        = string
  default     = "azuredisk-grafana"
}

variable "persistentVolumePrometheusServer" {
  description = "The name of a Persistent Volume for Prometheus Server."
  type        = string
  default     = "azuredisk-prometheus"
}

variable "persistentVolumePrometheusAlertManager" {
  description = "The name of a Persistent Volume for Prometheus Alert Manager."
  type        = string
  default     = "azuredisk-prometheus-alert"
}

variable "persistentVolumeGrafana" {
  description = "The name of a Persistent Volume for Grafana Server."
  type        = string
  default     = "azuredisk-grafana"
}

variable "prometheusServerPersistentVolumeClaim" {
  description = "A persistentVolumeClaim volume is used to mount a PersistentVolume into a Pod."
  type        = string
  default     = "prometheus-server"
}

variable "prometheusAlertManagerPersistentVolumeClaim" {
  description = "A persistentVolumeClaim volume is used to mount a PersistentVolume into a Pod."
  type        = string
  default     = "prometheus-alertmanager-0"
}

variable "grafanaPersistentVolumeClaim" {
  description = "A persistentVolumeClaim volume is used to mount a PersistentVolume into a Pod."
  type        = string
  default     = "grafana"
}

variable "storageSizePrometheusServer" {
  description = "Storage capacity is limited and may vary depending on the Persistent Volume."
  type        = string
  default     = "8Gi"
}

variable "storageSizePrometheusAlertManager" {
  description = "Storage capacity is limited and may vary depending on the Persistent Volume."
  type        = string
  default     = "2Gi"
}

variable "storageSizeGrafana" {
  description = "Storage capacity is limited and may vary depending on the Persistent Volume."
  type        = string
  default     = "10Gi"
}

variable "issuer_name_prod" {
  description = "The role issuer name for Issuer Prod."
  type        = string
  default     = "letsencrypt-prod"
}

variable "issuer_name_stage" {
  description = "The role issuer name for Issuer Stage."
  type        = string
  default     = "letsencrypt-stage"
}
