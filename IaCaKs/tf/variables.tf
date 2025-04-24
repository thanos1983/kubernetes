variable "environment" {
  description = "Environment (stage) where the resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure Region where the Resource Group should exist."
  type        = string
  default     = "North Europe"
}

variable "resource_group_name" {
  description = "The Name which should be used for this Resource Group."
  type        = string
}

variable "aks_cluster_name" {
  description = "The Azure Kubernetes Cluster Name (AKS)."
  type        = string
}

variable "default_node_pool_blocks" {
  description = "A default_node_pool block as defined below."
  type = list(object({
    name                        = string
    vm_size                     = string
    max_pods                    = number
    temporary_name_for_rotation = string
    node_count                  = number
    upgrade_settings_block = object({
      drain_timeout_in_minutes = optional(number)
      node_soak_duration_in_minutes = optional(number, 0)
      max_surge = string
    })
  }))
}

variable "sku_tier" {
  description = "The SKU Tier that should be used for this Kubernetes Cluster."
  type        = string
}

variable "directory_permission" {
  description = "Permissions to set for directories created (before umask), expressed as string in numeric notation."
  type        = string
  default     = "0644"
}

variable "file_permission" {
  description = "Permissions to set for the output file (before umask), expressed as string in numeric notation."
  type        = string
  default     = "0600"
}

# to be removed once the deployment is moved to a pipeline
variable "kubeConfigFilename" {
  description = "The path to the file that will be created. Missing parent directories will be created."
  type        = string
  default     = "kube/config"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type = map(any)
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed."
  type        = bool
  default     = true
}

variable "create_namespace" {
  description = "Create the namespace if it does not yet exist."
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

variable "ARM_SUBSCRIPTION_ID" {
  description = "The Subscription ID which should be used."
  type        = string
}

variable "cloudflare_api_token_name" {
  description = "The Cloudflare name for the API token for the specific case."
  type        = string
  default     = "external_dns"
}

variable "cloudflare_secretKeyRef_name" {
  description = "Name of secret for the DNS secret."
  type        = string
  default     = "cloudflare-api-key"
}

variable "cloudflare_secretKeyRef_key" {
  description = "Name of key for the DNS secret."
  type        = string
  default     = "apiKey"
}

variable "CLOUDFLARE_API_KEY" {
  description = "The API key for operations."
  type        = string
}

# variable "CLOUDFLARE_API_TOKEN" {
#  description = "The CloudFlare API token value."
#  type        = string
# }

variable "CLOUDFLARE_ZONE_ID" {
  description = "Zone ID (can be found on the UI)."
  type        = string
}

variable "CLOUDFLARE_EMAIL" {
  description = "A registered Cloudflare email address."
  type        = string
}

variable "MONITORING_BOOTSTRAP_PASSWORD" {
  description = "The bootstrap password for Grafana monitoring UI."
  type        = string
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

variable "acme_server_prod" {
  description = "The ACME server can successfully retrieve this key via a DNS lookup and can validate that the client owns the domain for the requested certificate for Prod."
  type        = string
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "acme_server_stage" {
  description = "The ACME server can successfully retrieve this key via a DNS lookup and can validate that the client owns the domain for the requested certificate for Stage."
  type        = string
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "secret_key_ref_prod" {
  description = "Secret resource that will be used to store the account's private key for Issuer Prod."
  type        = string
  default     = "letsencrypt-prod"
}

variable "secret_key_ref_stage" {
  description = "Secret resource that will be used to store the account's private key for Issuer Stage."
  type        = string
  default     = "letsencrypt-stage"
}

variable "ingressReplicaCount" {
  description = "How many pods should be deployed for the IngressController."
  type        = string
}

variable "load_config_file" {
  description = "Flag to enable/disable loading of the local kubeconf file."
  type        = bool
  default     = false
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

variable "sealed_secrets_namespace" {
  description = "The namespace where all sealed-secrets resources will be deployed."
  type        = string
  default     = "sealed-secrets"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS managed cluster."
  type        = string
}

variable "monitoring_namespace" {
  description = "The namespace where all monitoring resources will be deployed."
  type        = string
  default     = "monitoring"
}

variable "storage_account" {
  description = "Specifies the name of the Storage Account."
  type        = string
}

variable "public_network_access_enabled" {
  description = "Whether the public network access is enabled?"
  type        = bool
  default     = false
}

variable "knativeServingName" {
  description = "The name where the Knative Serving will be used after deployment."
  type        = string
  default     = "knative-serving"
}

variable "knativeServingNamespace" {
  description = "The namespace where the Knative Serving will be deployed."
  type        = string
  default     = "knative-serving"
}

variable "knativeOperatorVersion" {
  description = "The version of the Knative operator to deploy."
  type        = string
  default     = "1.17.3"
}

variable "knativeNetIstioVersion" {
  description = "The version of the Knative operator to deploy."
  type        = string
  default     = "1.17.0"
}

variable "knativeEventingName" {
  description = "The name where the Knative Eventing will be used as deployment."
  type        = string
  default     = "knative-eventing"
}

variable "knativeEventingNamespace" {
  description = "The namespace where the Knative Eventing will be deployed."
  type        = string
  default     = "knative-eventing"
}

variable "wait_for_rollout" {
  description = "Set this flag to wait or not for Deployments and APIService to complete rollout."
  type        = bool
  default     = false
}

variable "istio_namespace" {
  description = "The namespace in which ision core charts are to be installed."
  type        = string
  default     = "istio-system"
}

variable "open_service_mesh_enabled" {
  description = "Is Open Service Mesh enabled."
  type        = bool
  default     = false
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

variable "cloudFlareTypeDnsRecord" {
  description = "The type of the record."
  type = list(string)
  default = ["A", "TXT"]
}

variable "ttl" {
  description = "Time To Live (TTL) of the DNS record in seconds."
  type        = number
  default     = 1
}

variable "demoNamespace" {
  description = "The namespace that we will use for Demo."
  type        = string
  default     = "demo"
}

variable "demoOpenAiReferenceKey" {
  description = "The key name of the OpenAI primary key."
  type        = string
  default     = "openai_key"
}

variable "reflection-allowed-namespaces" {
  description = "Control the namespaces we want to replicate a Secret(s) of the reflector. Add more by separating them by coma."
  type        = string
  default     = "demo-dev,demo-sit,demo-uat,demo-prod"
}

variable "apply_retry_count" {
  description = "Defines the number of attempts any create/update action will take."
  type        = number
  default     = 3
}

variable "aks_role_definition_names" {
  description = "The role definition name(s) of the aks cluster."
  type = list(string)
  default = ["Azure Kubernetes Service RBAC Cluster Admin"]
}

variable "user_role_definition_names" {
  description = "The role definition name(s) of the aks cluster."
  type = list(string)
  default = ["Network Contributor"]
}

variable "network_plugin" {
  description = "Network plugin to use for networking."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Sets up network policy to be used with Azure CNI."
  type        = string
  default     = "calico"
}

variable "service_endpoints" {
  description = "The list of Service endpoints to associate with the subnet."
  type = list(string)
  default = ["Microsoft.AzureActiveDirectory", "Microsoft.ContainerRegistry", "Microsoft.Storage"]
}

variable "faasNamespace" {
  description = "The name space that we will use to deploy FaaS resources."
  type        = string
  default     = "faas"
}

variable "display_name_aad_group" {
  description = "The display name for the AAD group."
  type        = string
  default     = "DEMO_AKS_ADMIN_AAD_GROUP"
}

variable "security_enabled" {
  description = "Whether the group is a security group for controlling access to in-app resources."
  type        = bool
  default     = true
}

variable "assignable_to_role" {
  description = "Indicates whether this group can be assigned to an Azure Active Directory role."
  type        = bool
  default     = true
}

variable "description_aad_group" {
  description = "The description for the AAD group."
  type        = string
  default     = "This group is meant to be used by the AAD users that will be assigned as admin users of the AKS cluster."
}

variable "managed" {
  description = "Is the Azure Active Directory integration Managed, meaning that Azure will create/manage the Service Principal used for integration."
  type        = bool
  default     = true
}

variable "azure_rbac_enabled" {
  description = "Is Role Based Access Control based on Azure AD enabled?"
  type        = bool
  default     = false
}

variable "aksRoleAssignment" {
  description = "Azure role assignment for the Active Directory group."
  type        = string
  default     = "Azure Kubernetes Service Cluster User Role"
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

variable "ansible_hostname" {
  description = "The ip/name of the target host to use instead of inventory_hostname."
  type        = string
  default     = "localhost"
}

variable "ansible_connection" {
  description = "The connection plugin actually used for the task on the target host."
  type        = string
  default     = "local"
}

variable "status" {
  description = "Status of the token."
  type        = string
  default     = "active"
}
