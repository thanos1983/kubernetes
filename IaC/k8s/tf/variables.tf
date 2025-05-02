variable "location" {
  description = "The Azure Region where the Resource Group should exist."
  type        = string
  default     = "North Europe"
}

variable "admin_ssh_key_name" {
  description = "One or more admin_ssh_key blocks as defined below."
  type        = string
  default     = "tinyos"
}

variable "admin_ssh_key" {
  description = "One or more admin_ssh_key blocks as defined below."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "labels" {
  description = "A mapping of tags to assign to the resource."
  type = map(any)
}

variable "ARM_SUBSCRIPTION_ID" {
  description = "The Subscription ID which should be used."
  type        = string
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

variable "kubeConfigDestination" {
  description = "Location for the kube config file path."
  type        = string
  default     = "~/.kube/config"
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

variable "monitoring_namespace" {
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

variable "HETZNER_API_TOKEN" {
  description = "Hetzner Cloud API Token."
  type        = string
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

variable "ingressReplicaCount" {
  description = "How many pods should be deployed for the IngressController."
  type        = number
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

variable "username" {
  description = "Username for SSH to the server."
  type        = string
  default     = "tinyos"
}
