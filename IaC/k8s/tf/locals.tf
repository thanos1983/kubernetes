locals {
  knativeDomain         = "knative.${var.zone}"
  kubeConfigDestination = "${path.module}/kube/config"
  haproxy_k8s_nodes     = "${path.module}/${var.haproxy_k8s_nodes}"
  vault_file            = "${path.module}/roles/k8s/files/certificate-custom-key.yml"

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
        domain_name_label = "haproxy-new-vm"
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
            (local.master_nodes.master11.linux_virtual_machine.name) = local.master_nodes.master11.network_interface.ip_configuration.private_ip_address
            (local.master_nodes.master12.linux_virtual_machine.name) = local.master_nodes.master12.network_interface.ip_configuration.private_ip_address
            (local.master_nodes.master13.linux_virtual_machine.name) = local.master_nodes.master13.network_interface.ip_configuration.private_ip_address
          }
          config_worker = {
            (local.worker_nodes.worker11.linux_virtual_machine.name) = local.worker_nodes.worker11.network_interface.ip_configuration.private_ip_address
            (local.worker_nodes.worker12.linux_virtual_machine.name) = local.worker_nodes.worker12.network_interface.ip_configuration.private_ip_address
            (local.worker_nodes.worker13.linux_virtual_machine.name) = local.worker_nodes.worker13.network_interface.ip_configuration.private_ip_address
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
    master11 = {
      tags = ["k8sPrimeMasterNode"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master11-ip"
        allocation_method = "Static"
        domain_name_label = "master11-vm"
      }
      network_interface = {
        name                  = "nic-master11"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.13"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster11"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk11"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    master12 = {
      tags = ["k8sSecondaryMasterNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master12-ip"
        allocation_method = "Static"
        domain_name_label = "master12-vm"
      }
      network_interface = {
        name                  = "nic-master12"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.14"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster12"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk12"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    master13 = {
      tags = ["k8sSecondaryMasterNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "master13-ip"
        allocation_method = "Static"
        domain_name_label = "master13-vm"
      }
      network_interface = {
        name                  = "nic-master13"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.15"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmMaster13"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk13"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    }
  }

  worker_nodes = {
    worker11 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker11-ip"
        allocation_method = "Static"
        domain_name_label = "worker11-vm"
      }
      network_interface = {
        name                  = "nic-worker11"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.16"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker11"
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
    worker12 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker12-ip"
        allocation_method = "Static"
        domain_name_label = "worker12-vm"
      }
      network_interface = {
        name                  = "nic-worker12"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.17"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker12"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk12"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 32
        }
      }
    },
    worker13 = {
      tags = ["k8sWorkerNodes"]
      # tags = ["ping"]
      public_ip = {
        sku               = "Basic"
        name              = "worker13-ip"
        allocation_method = "Static"
        domain_name_label = "worker13-vm"
      }
      network_interface = {
        name                  = "nic-worker13"
        ip_forwarding_enabled = true
        ip_configuration = {
          name                          = "primary"
          private_ip_address_allocation = "Static"
          private_ip_address            = "10.240.0.18"
        }
      }
      linux_virtual_machine = {
        name = "linuxVmWorker13"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          KUBERNETES_VERSION = var.kubernetes_version
          CRIO_VERSION       = var.crio_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk13"
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

  azure_csi_driver = {
    create_namespace = false
    wait             = true
    wait_for_jobs    = false
    version          = "1.33.0"
    namespace        = var.kubeNamespace
    name             = "azuredisk-csi-driver"
    chart            = "azuredisk-csi-driver"
    repository       = "https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts"
    set_blocks = [
      {
        name  = "node.cloudConfigSecretName"
        value = var.cloudConfigSecretName
      },
      {
        name  = "node.cloudConfigSecretNamesapce"
        value = var.kubeNamespace
      },
      {
        name  = "controller.cloudConfigSecretName"
        value = var.cloudConfigSecretName
      },
      {
        name  = "controller.cloudConfigSecretNamespace"
        value = var.kubeNamespace
      }
    ]
    values = []
  }

  istio-base = {
    wait             = true
    create_namespace = false
    wait_for_jobs    = false
    chart            = "base"
    version          = "1.25.2"
    name             = "istio-base"
    namespace        = var.istioNamespace
    repository       = "https://istio-release.storage.googleapis.com/charts"
    set_blocks = [
      {
        name  = "defaultRevision"
        value = "default"
      }
    ]
    values = []
  }

  istio-discovery = {
    create_namespace = false
    wait             = true
    wait_for_jobs    = true
    chart            = "istiod"
    version          = "1.25.2"
    name             = "istio-discovery"
    namespace        = var.istioNamespace
    repository       = "https://istio-release.storage.googleapis.com/charts"
    set_blocks = [
      {
        name  = "profile"
        value = "ambient"
      },
      {
        name  = "meshConfig.accessLogFile"
        value = "/dev/stdout"
      }
    ]
    values = []
  }

  istio-cni = {
    create_namespace = false
    wait             = true
    wait_for_jobs    = false
    chart            = "cni"
    version          = "1.25.2"
    name             = "istio-cni"
    namespace        = var.istioNamespace
    repository       = "https://istio-release.storage.googleapis.com/charts"
    set_blocks = [
      {
        name  = "profile"
        value = "ambient"
      }
    ]
    values = []
  }

  istio-ztunnel = {
    create_namespace = false
    wait             = true
    wait_for_jobs    = false
    chart            = "ztunnel"
    version          = "1.25.2"
    name             = "istio-ztunnel"
    namespace        = var.istioNamespace
    repository       = "https://istio-release.storage.googleapis.com/charts"
    set_blocks = []
    values = []
  }

  istio-gateway = {
    create_namespace = false
    wait             = false
    wait_for_jobs    = true
    version          = "1.25.2"
    chart            = "gateway"
    namespace        = var.istioNamespace
    name             = "istio-ingressgateway"
    repository       = "https://istio-release.storage.googleapis.com/charts"
    set_blocks = [
      {
        name  = "replicaCount"
        value = var.ingressReplicaCount
      },
      {
        name  = "service.autoscaling.minReplicas"
        value = var.ingressReplicaCount
      },
      {
        name  = "service.loadBalancerIP"
        value = module.project_nodes_public_ips["haProxyLB"].ip_address
      }
    ]
    values = [
      templatefile("${path.module}/helmIngressIstioGatewayValues/values.yaml.tpl", {
        zones = "www.${var.zone},${var.zone}"
        externalIPs = [module.project_nodes_public_ips["haProxyLB"].ip_address]
      })
    ]
  }

  helm_prime_packages = {
    calico = {
      wait             = true
      wait_for_jobs    = false
      create_namespace = true
      version          = "3.30.0"
      name             = "projectcalico"
      chart            = "tigera-operator"
      namespace        = "tigera-operator"
      repository       = "https://docs.tigera.io/calico/charts"
      set_blocks = []
      values = [
        templatefile("${path.module}/calico/values.yaml.tpl", {
          podNetworkCidr = var.podNetworkCidr
        })
      ]
    },
    cert-manager = {
      wait             = true
      wait_for_jobs    = true
      create_namespace = false
      version          = "1.17.2"
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
    metrics_server = {
      wait             = false
      wait_for_jobs    = false
      create_namespace = false
      version          = "3.12.2"
      name             = "metrics-server"
      chart            = "metrics-server"
      namespace        = var.kubeNamespace
      repository       = "https://kubernetes-sigs.github.io/metrics-server/"
      set_blocks = []
      values = [
        file("${path.module}/metricsServer/values.yaml")
      ]
    }
  }

  helm_deployment = {
    # argo-cd = {
    #   create_namespace = true
    #   wait             = true
    #   wait_for_jobs    = false
    #   version          = "7.8.28"
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
    external-dns = {
      create_namespace = false
      wait             = true
      wait_for_jobs    = false
      version          = "1.16.1"
      name             = "external-dns"
      chart            = "external-dns"
      namespace        = var.certManagerNamespace
      repository       = "https://kubernetes-sigs.github.io/external-dns"
      set_blocks = []
      values = [
        templatefile("${path.module}/helmExternalDnsValues/cloudflare.yaml.tpl", {
          txtOwnerId                   = var.CLOUDFLARE_ZONE_ID
          cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
          cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name
        })
      ]
    },
    # loki = { # Do not uncomment
    #   create_namespace = true
    #   wait             = true
    #   wait_for_jobs    = false
    #   version          = "6.29.0"
    #   name             = "loki"
    #   chart            = "loki"
    #   namespace        = var.monitoringNamespace
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
    prometheus = {
      wait             = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "27.16.0"
      name             = "prometheus"
      chart            = "prometheus"
      namespace        = var.monitoringNamespace
      repository       = "https://prometheus-community.github.io/helm-charts"
      set_blocks = []
      values = [
        templatefile("${path.module}/helmPrometheusValues/values.yaml.tpl", {
          storageClass  = var.storageClassPrometheus
          existingClaim = var.prometheusServerPersistentVolumeClaim
          config_labels = {
            "app.kubernetes.io/name"      = "prometheus"
            "app.kubernetes.io/component" = "server"
            "app.kubernetes.io/instance"  = "prometheus"
          }
        })
      ]
    },
    #   promtail = {
    #     create_namespace = true
    #     wait             = true
    #     wait_for_jobs    = false
    #     version          = "6.16.6"
    #     name             = "promtail"
    #     chart            = "promtail"
    #     namespace        = var.monitoringNamespace
    #     repository       = "https://grafana.github.io/helm-charts"
    #     set_blocks = []
    #     values = []
    #   },
    #   qdrant = {
    #     create_namespace = true
    #     wait             = true
    #     wait_for_jobs    = false
    #     version          = "1.14.0"
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
      version          = "9.0.344"
      chart            = "reflector"
      name             = "emberstack"
      namespace        = var.kubeNamespace
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

  post_helm_deployment = {
    grafana = {
      create_namespace = false
      wait             = true
      wait_for_jobs    = false
      version          = "9.0.0"
      name             = "grafana"
      chart            = "grafana"
      namespace        = var.monitoringNamespace
      repository       = "https://grafana.github.io/helm-charts"
      set_blocks = []
      values = [
        templatefile("${path.module}/helmGrafanaValues/values.yaml.tpl", {
          namespace     = "monitoring"
          size          = var.storageSizeGrafana
          storageClass  = var.storageClassGrafana
          existingClaim = var.grafanaPersistentVolumeClaim
          adminPassword = var.MONITORING_BOOTSTRAP_PASSWORD
          defaultRegion = module.project_resource_group.location
          # lokiUrl       = "http://loki-gateway.${var.monitoringNamespace}.svc.cluster.local:80"
          prometheusUrl = "http://prometheus-server.${var.monitoringNamespace}.svc.cluster.local:80"
          config_labels = {
            "app.kubernetes.io/name"     = "grafana"
            "app.kubernetes.io/instance" = "grafana"
          }
        })
      ]
    },
  }

  knative = {
    operator = {
      filename = "${path.module}/roles/knative/files/operator.yaml"
      content = replace(data.http.knative_operator.response_body, "initialDelaySeconds: 120", "initialDelaySeconds: 180")
    }
    net_istio = {
      filename = "${path.module}/roles/knative/files/net-istio.yaml"
      content  = data.http.net_istio.response_body
    }
  }

  secret_reflector = {
    qdrant = {
      api_version = "v1"
      kind        = "Secret"
      annotations = {
        "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
        "reflector.v1.k8s.emberstack.com/reflection-auto-enabled"       = "true"
        "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces"    = var.reflection-allowed-namespaces
        "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = var.reflection-allowed-namespaces
      }
      metadata = {
        name      = "qdrant-apikey"
        namespace = var.qdrant_namespace
      }
    }
  }

  istioGateway = {
    grafana = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      gatewayTlsMode                               = "SIMPLE"
      component                                    = "grafana"
      gatewaySelector                              = "ingressgateway"
      certificateNamespace                         = var.istioNamespace
      certificateIssuerRefName                     = var.issuer_name_prod
      hosts                                        = "grafana.${var.zone}"
      commonName                                   = "grafana.${var.zone}"
      namespace                                    = var.monitoringNamespace
      gatewayName                                  = "istio-ingressgateway-grafana"
      virtualServiceName                           = "istio-virtualservice-grafana"
      secretName                                   = "grafana-${var.issuer_name_prod}"
      virtualServiceHttpRouteDestinationHost       = "grafana.${var.monitoringNamespace}.svc.cluster.local"
      virtualServiceGateways                       = "${var.monitoringNamespace}/istio-ingressgateway-grafana"
    },
    prometheus = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      gatewayTlsMode                               = "SIMPLE"
      component                                    = "prometheus"
      gatewaySelector                              = "ingressgateway"
      certificateNamespace                         = var.istioNamespace
      certificateIssuerRefName                     = var.issuer_name_prod
      namespace                                    = var.monitoringNamespace
      hosts                                        = "prometheus.${var.zone}"
      commonName                                   = "prometheus.${var.zone}"
      gatewayName                                  = "istio-ingressgateway-prometheus"
      virtualServiceName                           = "istio-virtualservice-prometheus"
      secretName                                   = "prometheus-${var.issuer_name_prod}"
      virtualServiceGateways                       = "${var.monitoringNamespace}/istio-ingressgateway-prometheus"
      virtualServiceHttpRouteDestinationHost       = "prometheus-server.${var.monitoringNamespace}.svc.cluster.local"
    }
  }

  istioGatewayKubectl = {
    grafanaGateway = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "grafana"
          "app.kubernetes.io/name"      = "grafanaGateway"
          "app.kubernetes.io/instance"  = "grafana-terraform"
        }
        gatewayName      = "istio-ingressgateway-grafana"
        gatewayNamespace = var.monitoringNamespace
        gatewaySelector  = "ingressgateway"
        gatewayTlsMode   = "SIMPLE "
        secretName       = "grafana-${var.issuer_name_prod}"
        hosts = ["grafana.${var.zone}"]
      })
    },
    grafanaCertificate = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/certificate.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "grafana"
          "app.kubernetes.io/instance"  = "grafana-terraform"
          "app.kubernetes.io/name"      = "grafanaCertificate"
        }
        secretName               = "grafana-${var.issuer_name_prod}"
        certificateNamespace     = var.istioNamespace
        certificateIssuerRefName = var.issuer_name_prod
        commonName               = "grafana.${var.zone}"
        hosts = ["grafana.${var.zone}"]
      })
    },
    grafanaVirtualService = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/virtualService.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "grafana"
          "app.kubernetes.io/instance"  = "grafana-terraform"
          "app.kubernetes.io/name"      = "grafanaVirtualService"
        }
        virtualServiceName                           = "istio-virtualservice-grafana"
        virtualServiceNamespace                      = var.monitoringNamespace
        virtualServiceHttpMatchUriPrefix             = "/"
        virtualServiceHttpRouteDestinationHost       = "grafana.${var.monitoringNamespace}.svc.cluster.local"
        virtualServiceHttpRouteDestinationPortNumber = 80
        hosts = ["grafana.${var.zone}"]
        virtualServiceGateways = ["${var.monitoringNamespace}/istio-ingressgateway-grafana"]
      })
    },
    prometheusGateway = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/name"      = "prometheusGateway"
          "app.kubernetes.io/instance"  = "prometheus-terraform"
        }
        gatewayNamespace = var.monitoringNamespace
        gatewayName      = "istio-ingressgateway-prometheus"
        gatewaySelector  = "ingressgateway"
        gatewayTlsMode   = "SIMPLE "
        secretName       = "prometheus-${var.issuer_name_prod}"
        hosts = ["prometheus.${var.zone}"]
      })
    },
    prometheusCertificate = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/certificate.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance"  = "prometheus-terraform"
          "app.kubernetes.io/name"      = "prometheusCertificate"
        }
        secretName               = "prometheus-${var.issuer_name_prod}"
        certificateNamespace     = var.istioNamespace
        certificateIssuerRefName = var.issuer_name_prod
        commonName               = "prometheus.${var.zone}"
        hosts = ["prometheus.${var.zone}"]
      })
    },
    prometheusVirtualService = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/virtualService.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/instance"  = "prometheus-terraform"
          "app.kubernetes.io/name"      = "prometheusVirtualService"
        }
        virtualServiceName                           = "istio-virtualservice-prometheus"
        virtualServiceNamespace                      = var.monitoringNamespace
        virtualServiceHttpMatchUriPrefix             = "/"
        virtualServiceHttpRouteDestinationHost       = "prometheus-server.${var.monitoringNamespace}.svc.cluster.local"
        virtualServiceHttpRouteDestinationPortNumber = 80
        hosts = ["prometheus.${var.zone}"]
        virtualServiceGateways = ["${var.monitoringNamespace}/istio-ingressgateway-prometheus"]
      })
    },
  }
}

# User permissions
data "azuread_client_config" "current" {}
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "subscription" {}

data "http" "knative_operator" {
  url = "https://github.com/knative/operator/releases/download/knative-v${var.knativeOperatorVersion}/operator.yaml"
}

data "http" "net_istio" {
  url = "https://github.com/knative/net-istio/releases/download/knative-v${var.knativeNetIstioVersion}/net-istio.yaml"
}

# data "kubectl_file_documents" "knative_operator" {
#   content = replace(data.http.knative_operator.response_body, "initialDelaySeconds: 120", "initialDelaySeconds: 180")
# }
#
# data "kubectl_file_documents" "net_istio" {
#   content = data.http.net_istio.response_body
# }