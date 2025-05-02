locals {
  knativeDomain     = "knative.${var.zone}"
  haproxy_k8s_nodes = "${path.module}/${var.haproxy_k8s_nodes}"

  cloudFlareTypeDnsRecord = {
    knative = {
      comment = "Primary record for Knative (subdomains) needed to trigger DNS resolution and subsequent."
      type    = "A"
      ttl     = var.ttl
      name    = "*.${local.knativeDomain}"
      content = module.project_nodes_public_ips["haProxyLB"].ip_address
    }
  }

  haPoxyLoadBalancer = {
    haProxyLB = {
      tags = ["highAvailabilityProxy"]
      # tags = ["ping"]
      keepalived = {
        filename = "${path.module}/${var.haproxy_keepalived_nodes}/keepalivedPrime.cfg"
        state    = "MASTER"
        priority = 255
        ip_addrs_of_peers = ["10.240.0.12"]
      }
      public_ip = {
        sku               = "Basic"
        name              = "haProxy-ip"
        allocation_method = "Static"
        domain_name_label = "haproxy-vm"
      }
      network_interface = {
        name                  = "nic-haProxy"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.11"
        }
      }
      linux_virtual_machine = {
        name = "linuxHaProxy"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/haproxy-cloud-init.tftpl", {
          HAPROXY_STATS_URI_PATH              = var.haProxyStatsUriPath
          HAPROXY_STATS_BIND_PORT             = var.haProxyStatsBindPort
          NODE_PORT_HTTP                      = var.kubeServerNodePortHttp
          NODE_PORT_HTTPS                     = var.kubeServerNodePortHttps
          HAPROXY_STATS_WEB_PAGE_REFRESH_RATE = var.haProxyStatsRefreshRate
          APISERVER_BIND_PORT                 = var.kubeServerApiServerBindPort
          config_master = {
            (local.master_nodes.master01.linux_virtual_machine.name) = local.master_nodes.master01.network_interface.ip_configuration.private_ip_address
            (local.master_nodes.master02.linux_virtual_machine.name) = local.master_nodes.master02.network_interface.ip_configuration.private_ip_address
            (local.master_nodes.master03.linux_virtual_machine.name) = local.master_nodes.master03.network_interface.ip_configuration.private_ip_address
          }
          config_worker = {
            (local.worker_nodes.worker01.linux_virtual_machine.name) = local.worker_nodes.worker01.network_interface.ip_configuration.private_ip_address
            (local.worker_nodes.worker02.linux_virtual_machine.name) = local.worker_nodes.worker02.network_interface.ip_configuration.private_ip_address
            (local.worker_nodes.worker03.linux_virtual_machine.name) = local.worker_nodes.worker03.network_interface.ip_configuration.private_ip_address
          }
        }))
        os_disk = {
          name                 = "linuxHaProxyDisk"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    }
  }

  master_nodes = {
    master01 = {
      tags = ["k8sPrimeMasterNode"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master01-ip"
        allocation_method = "Static"
        domain_name_label = "master01-vm"
      }
      network_interface = {
        name                  = "nic-master01"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.13"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster01"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk01"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    master02 = {
      tags = ["k8sSecondaryMasterNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master02-ip"
        allocation_method = "Static"
        domain_name_label = "master02-vm"
      }
      network_interface = {
        name                  = "nic-master02"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.14"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster02"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk02"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    master03 = {
      tags = ["k8sSecondaryMasterNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master03-ip"
        allocation_method = "Static"
        domain_name_label = "master03-vm"
      }
      network_interface = {
        name                  = "nic-master03"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.15"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster03"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk03"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    }
  }

  worker_nodes = {
    worker01 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker01-ip"
        allocation_method = "Static"
        domain_name_label = "worker01-vm"
      }
      network_interface = {
        name                  = "nic-worker01"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.16"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker01"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk01"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    worker02 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker02-ip"
        allocation_method = "Static"
        domain_name_label = "worker02-vm"
      }
      network_interface = {
        name                  = "nic-worker02"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.17"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker02"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk02"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    worker03 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker03-ip"
        allocation_method = "Static"
        domain_name_label = "worker03-vm"
      }
      network_interface = {
        name                  = "nic-worker03"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.18"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker03"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk03"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    }
  }

  network = {
    virtual_network = {
      address_space = ["10.240.0.0/16"]
      name = "k8s-${var.environment}-vnet"
      subnet = {
        k8s = {
          address_prefixes = ["10.240.0.0/16"]
          name = "k8sNodesSubnet"
        }
      }
    }
  }

  security_rules = [
    {
      name                       = "SSH"
      priority                   = 100
      description                = "SSH rule port 22."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    },
    {
      name                       = "kubeapiserver"
      priority                   = 200
      description                = "Kube API rule port 6443."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "6443"
    },
    {
      name                       = "ICMP"
      priority                   = 300
      description                = "ICMP rule."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "*"
    },
    {
      name                       = "HTTP"
      priority                   = 400
      description                = "HTTP rule port 80."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "80"
    },
    {
      name                       = "HTTPS"
      priority                   = 500
      description                = "HTTPS rule port 443."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "443"
    },
    {
      name                       = "NodePorts"
      priority                   = 600
      description                = "NodePorts rule port range 30000-32767."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "30000-32767"
    },
    {
      name                       = "HAProxy_Stats"
      priority                   = 700
      description                = "Exposing port 9000 for HAProxy Stats page."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "9000"
    }
  ]

  nsg_rules_master_nodes = [
    {
      name                       = "SSH"
      priority                   = 100
      description                = "SSH rule port 22."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    }, {
      name                       = "kubeapiserver"
      priority                   = 200
      description                = "Kube API rule port 6443."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "6443"
    }, {
      name                       = "kubeapiserver"
      priority                   = 300
      description                = "Kube port range 2379-2380."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "2379-2380"
    }, {
      name                       = "kubeapiserver"
      priority                   = 400
      description                = "Kube port range 10250-10251."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "10250-10251"
    }
  ]

  nsg_rules_worker_nodes = [
    {
      name                       = "SSH"
      priority                   = 100
      description                = "SSH rule port 22."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
    }, {
      name                       = "kubeapiclient"
      priority                   = 200
      description                = "Kube API rule port 10250."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Icmp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "10250"
    }, {
      name                       = "kubeapiclient"
      priority                   = 300
      description                = "Kube port range 30000-32767."
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "30000-32767"
    }
  ]

  cloudflare_policies = [
    {
      effect = "allow"
      permission_groups = [
        {
          # taken from data.cloudflare_api_token_permissions_groups_list.api_token_permissions_groups
          id = "c8fed203ed3043cba015a93ad1616f1f" # Zone Read
        },
        {
          # taken from data.cloudflare_api_token_permissions_groups_list.api_token_permissions_groups
          id = "4755a26eedb94da69e1066d98aa820be" # DNS Write
        }
      ]
      resources = {
        "com.cloudflare.api.account.zone.*" = "*"
      }
    }
  ]

  helm_deployment_dependencies = {
    # argo-cd = {
    #   create_namespace = true
    #   wait             = true
    #   wait_for_jobs    = false
    #   version          = "7.8.18"
    #   name             = "argo-cd"
    #   chart            = "argo-cd"
    #   namespace        = var.argoCdNamespace
    #   repository       = "https://argoproj.github.io/argo-helm"
    #   set_blocks = [
    #     {
    #       # Run server without TLS
    #       name  = "configs.params.server\\.insecure"
    #       value = true
    #     }
    #   ]
    #   values = [
    #     file("${path.module}/argoCD/values.yaml")
    #   ]
    # },
    cert-manager = {
      wait             = true
      wait_for_jobs    = true
      create_namespace = false
      version          = "1.17.1"
      name             = "cert-manager"
      chart            = "cert-manager"
      namespace        = var.certManagerNamespace
      repository       = "https://charts.jetstack.io"
      set_blocks = [
        {
          name  = "crds.enabled"
          value = true
        },
        {
          name  = "prometheus.enabled"
          value = true
        }
      ]
      values = []
    },
    external-dns = {
      create_namespace = false
      wait             = true
      wait_for_jobs    = false
      version          = "1.16.0"
      name             = "external-dns"
      chart            = "external-dns"
      namespace        = var.certManagerNamespace
      repository       = "https://kubernetes-sigs.github.io/external-dns"
      set_blocks = []
      values = [
        templatefile("${path.module}/helmExternalDnsValues/cloudflare.yaml.tpl", {
          txtOwnerId                   = var.CLOUDFLARE_ZONE_ID
          cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name
          cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
        })
      ]
    },
    # grafana = {
    #   create_namespace = true
    #   wait             = true
    #   wait_for_jobs    = false
    #   version          = "8.11.0"
    #   name             = "grafana"
    #   chart            = "grafana"
    #   namespace        = var.monitoring_namespace
    #   repository       = "https://grafana.github.io/helm-charts"
    #   set_blocks = []
    #   values = [
    #     templatefile("${path.module}/helmGrafanaValues/values.yaml.tpl", {
    #       namespace     = "monitoring"
    #       adminPassword = var.MONITORING_BOOTSTRAP_PASSWORD
    #       defaultRegion = module.project_resource_group.location
    #       # lokiUrl       = "http://loki-gateway.${var.monitoring_namespace}.svc.cluster.local:80"
    #       prometheusUrl = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local:80"
    #     })
    #   ]
    # },
    ingress-nginx = {
      create_namespace = true
      wait             = false
      wait_for_jobs    = false
      version          = "4.12.1"
      name             = "ingress-nginx"
      namespace        = "ingress-nginx"
      chart            = "ingress-nginx"
      repository       = "https://kubernetes.github.io/ingress-nginx"
      set_blocks = [
        {
          name  = "controller.service.nodePorts.http"
          value = var.kubeServerNodePortHttp
        },
        {
          name  = "controller.service.nodePorts.https"
          value = var.kubeServerNodePortHttps
        },
        {
          name  = "controller.replicaCount"
          value = var.ingressReplicaCount
        },
        {
          name  = "controller.service.loadBalancerIP"
          value = module.project_nodes_public_ips["haProxyLB"].ip_address
        },
        {
          name  = "controller.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/ttl"
          value = "120"
        },
        {
          name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
          value = "/healthz"
        }
      ]
      values = [
        templatefile("${path.module}/helmIngressNginxValues/values.yaml.tpl", {
          externalIPs = [module.project_nodes_public_ips["haProxyLB"].ip_address]
          zones = "www.${var.zone},${var.zone}"
        })
      ]
    },
    # loki = { # Do not uncomment
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "6.29.0"
    #   name             = "loki"
    #   chart            = "loki"
    #   namespace        = var.monitoring_namespace
    #   repository       = "https://grafana.github.io/helm-charts"
    #   set_blocks = []
    #   values = [
    #     templatefile("${path.module}/helmLokiValues/values.yaml.tpl", {
    #       requestTimeout   = "10s"
    #       accountName      = module.projekt_storage_account.name
    #       accountKey       = module.projekt_storage_account.primary_access_key
    #       connectionString = module.projekt_storage_account.primary_connection_string
    #     })
    #   ]
    # },
    # prometheus = {
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "27.7.1"
    #   name             = "prometheus"
    #   chart            = "prometheus"
    #   namespace        = var.monitoring_namespace
    #   repository       = "https://prometheus-community.github.io/helm-charts"
    #   set_blocks = []
    #   values = [
    #     file("${path.module}/helmPrometheusValues/values.yaml")
    #   ]
    # },
    #   promtail = {
    #     create_namespace = true
    #     wait_for_jobs    = false
    #     version          = "6.16.6"
    #     name             = "promtail"
    #     chart            = "promtail"
    #     namespace        = var.monitoring_namespace
    #     repository       = "https://grafana.github.io/helm-charts"
    #     set_blocks = []
    #     values = []
    #   },
    #   qdrant = {
    #     create_namespace = true
    #     wait_for_jobs    = false
    #     version          = "1.13.6"
    #     name             = "qdrant"
    #     chart            = "qdrant"
    #     namespace        = var.qdrant_namespace
    #     repository       = "https://qdrant.github.io/qdrant-helm"
    #     set_blocks = [
    #       {
    #         name  = "replicaCount"
    #         value = var.qdrant_replicaCount
    #       }
    #     ]
    #     values = [
    #       file("${path.module}/helmQdrantValues/values.yaml")
    #     ]
    #   },
    reflector = {
      create_namespace = false
      wait             = true
      wait_for_jobs    = false
      version          = "9.0.322"
      chart            = "reflector"
      name             = "emberstack"
      namespace        = "kube-system"
      repository       = "https://emberstack.github.io/helm-charts"
      set_blocks = []
      values = []
    },
    sealed-secrets = {
      create_namespace = true
      wait             = true
      wait_for_jobs    = false
      version          = "2.17.2"
      name             = "sealed-secrets"
      chart            = "sealed-secrets"
      namespace        = var.sealed_secrets_namespace
      repository       = "https://bitnami-labs.github.io/sealed-secrets"
      set_blocks = []
      values = []
    }
  }
}

# User permissions
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "subscription" {}
