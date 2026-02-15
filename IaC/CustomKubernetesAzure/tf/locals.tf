locals {
  knativeDomain         = "knative.${var.zone}"
  kubeConfigDestination = "${path.module}/kube/config"
  vault_dir_file        = "${path.module}/vault/vault.yml"
  haproxy_k8s_nodes     = "${path.module}/${var.haproxy_k8s_nodes}"
  decoded_vault_yaml    = yamldecode(module.project_ansible_vault.yaml)
  vault_file            = "${path.module}/roles/k8s/files/certificate-custom-key.yml"

  storage_account_container = {
    chunks = {
      name = "loki-azure-dev-chunks"
    }
    ruler = {
      name = "loki-azure-dev-ruler"
    }
    admin = {
      name = "loki-azure-dev-admin"
    }
    tempo = {
      name = "tempo-container"
    }
  }

  persistentStorage = {
    prometheus_server = {
      storageClass = {
        metadata = {
          name = var.managedDisks["prometheus"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["prometheus"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["prometheus"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "8Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["prometheus"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["prometheus"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["prometheus"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["prometheus"].storage_class_name
          volumeName       = var.managedDisks["prometheus"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "8Gi"
            }
          }
        }
      }
    },
    prometheus_alertmanager = {
      storageClass = {
        metadata = {
          name = var.managedDisks["prometheus"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["prometheus"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = "azuredisk-prometheus-alert"
        }
        spec = {
          capacity = {
            storage = "2Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["prometheus"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["prometheus"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = "storage-prometheus-alertmanager-0"
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["prometheus"].storage_class_name
          volumeName       = "azuredisk-prometheus-alert"
          accessModes      = ["ReadWriteOnce"]
          resources = {
            requests = {
              storage = "2Gi"
            }
          }
        }
      }
    },
    grafana = {
      storageClass = {
        metadata = {
          name = var.managedDisks["grafana"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["grafana"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["grafana"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["grafana"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["grafana"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["grafana"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["grafana"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["grafana"].storage_class_name
          volumeName       = var.managedDisks["grafana"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["grafana"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-backend-0 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-backend-0"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-backend-0"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-backend-0"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-backend-0"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-backend-0"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-backend-0"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-backend-0"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-backend-0"].storage_class_name
          volumeName       = var.managedDisks["loki-backend-0"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-backend-0"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-backend-1 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-backend-1"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-backend-1"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-backend-1"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-backend-1"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-backend-1"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-backend-1"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-backend-1"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-backend-1"].storage_class_name
          volumeName       = var.managedDisks["loki-backend-1"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-backend-1"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-backend-2 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-backend-2"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-backend-2"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-backend-2"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-backend-2"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-backend-2"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-backend-2"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-backend-2"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-backend-2"].storage_class_name
          volumeName       = var.managedDisks["loki-backend-2"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-backend-2"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-write-0 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-write-0"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-write-0"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-write-0"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-write-0"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-write-0"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-write-0"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-write-0"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-write-0"].storage_class_name
          volumeName       = var.managedDisks["loki-write-0"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-write-0"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-write-1 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-write-1"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-write-1"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-write-1"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-write-1"].disk_size_gb}Gi"
          }
          accessModes                   = ["ReadWriteOnce"]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-write-1"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-write-1"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-write-1"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-write-1"].storage_class_name
          volumeName       = var.managedDisks["loki-write-1"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-write-1"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    loki-write-2 = {
      storageClass = {
        metadata = {
          name = var.managedDisks["loki-write-2"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["loki-write-2"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["loki-write-2"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["loki-write-2"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["loki-write-2"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["loki-write-2"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["loki-write-2"].persistent_volume_claim
          namespace = var.monitoringNamespace
        }
        spec = {
          storageClassName = var.managedDisks["loki-write-2"].storage_class_name
          volumeName       = var.managedDisks["loki-write-2"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["loki-write-2"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    ollama = {
      storageClass = {
        metadata = {
          name = var.managedDisks["ollama"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["ollama"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["ollama"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["ollama"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["ollama"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["ollama"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["ollama"].persistent_volume_claim
          namespace = var.openWebuiNamespace
        }
        spec = {
          storageClassName = var.managedDisks["ollama"].storage_class_name
          volumeName       = var.managedDisks["ollama"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["ollama"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    openwebui = {
      storageClass = {
        metadata = {
          name = var.managedDisks["openwebui"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["openwebui"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["openwebui"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["openwebui"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["openwebui"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["openwebui"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["openwebui"].persistent_volume_claim
          namespace = var.openWebuiNamespace
          labels = {
            "app.kubernetes.io/managed-by" = "Helm"
          }
          annotations = {
            "meta.helm.sh/release-name"      = "open-webui"
            "meta.helm.sh/release-namespace" = var.openWebuiNamespace
          }
        }
        spec = {
          storageClassName = var.managedDisks["openwebui"].storage_class_name
          volumeName       = var.managedDisks["openwebui"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["openwebui"].disk_size_gb}Gi"
            }
          }
        }
      }
    },
    openwebuiPipelines = {
      storageClass = {
        metadata = {
          name = var.managedDisks["openwebui-pipelines"].storage_class_name
        }
        provisioner = var.storageClassProvisioner
        parameters = {
          skuName = var.managedDisks["openwebui-pipelines"].storage_account_type
        }
        reclaimPolicy        = "Retain"
        volumeBindingMode    = "Immediate"
        allowVolumeExpansion = false
      }
      persistentVolume = {
        metadata = {
          name = var.managedDisks["openwebui-pipelines"].persistent_volume_name
        }
        spec = {
          capacity = {
            storage = "${var.managedDisks["openwebui-pipelines"].disk_size_gb}Gi"
          }
          accessModes = [
            "ReadWriteOnce"
          ]
          persistentVolumeReclaimPolicy = "Retain"
          storageClassName              = var.managedDisks["openwebui-pipelines"].storage_class_name
          csi = {
            driver       = var.storageClassProvisioner
            readOnly     = false
            volumeHandle = module.project_azure_disks["openwebui-pipelines"].id
            volumeAttributes = {
              cachingMode = "ReadOnly"
              fsType      = "ext4"
            }
          }
        }
      }
      persistentVolumeClaim = {
        metadata = {
          name      = var.managedDisks["openwebui-pipelines"].persistent_volume_claim
          namespace = var.openWebuiNamespace
          labels = {
            "app.kubernetes.io/managed-by" = "Helm"
          }
          annotations = {
            "meta.helm.sh/release-name"      = "open-webui"
            "meta.helm.sh/release-namespace" = var.openWebuiNamespace
          }
        }
        spec = {
          storageClassName = var.managedDisks["openwebui-pipelines"].storage_class_name
          volumeName       = var.managedDisks["openwebui-pipelines"].persistent_volume_name
          accessModes = [
            "ReadWriteOnce"
          ]
          resources = {
            requests = {
              storage = "${var.managedDisks["openwebui-pipelines"].disk_size_gb}Gi"
            }
          }
        }
      }
    }
  }

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
        filename          = "${path.module}/${var.haproxy_keepalived_nodes}/keepalivedPrime.cfg"
        state             = "MASTER"
        priority          = 255
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
          admin_username                      = var.username
          HAPROXY_STATS_URI_PATH              = var.haProxyStatsUriPath
          HAPROXY_STATS_BIND_PORT             = var.haProxyStatsBindPort
          NODE_PORT_HTTP                      = var.kubeServerNodePortHttp
          NODE_PORT_HTTPS                     = var.kubeServerNodePortHttps
          HAPROXY_STATS_WEB_PAGE_REFRESH_RATE = var.haProxyStatsRefreshRate
          APISERVER_BIND_PORT                 = var.kubeServerApiServerBindPort
          HAPROXY_USERNAME                    = local.decoded_vault_yaml.monitoring.haproxy.username
          HAPROXY_PASSWORD                    = local.decoded_vault_yaml.monitoring.haproxy.password
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
        name = "linuxVmmaster01"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk11"
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
        name = "linuxVmmaster02"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
        }))
        os_disk = {
          name                 = "linuxVmMasterDisk12"
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
        name = "linuxVmmaster03"
        size = "Standard_B2als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
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
        name = "linuxVmworker01"
        size = "Standard_B8als_v2" # "Standard_B4als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk01"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 64
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
        name = "linuxVmworker02"
        size = "Standard_B8als_v2" # "Standard_B4als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk12"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 64
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
        name = "linuxVmworker03"
        size = "Standard_B8als_v2" # "Standard_B4als_v2"
        custom_data = base64encode(templatefile("${path.module}/templates/k8s-cloud-init.tftpl", {
          admin_username     = var.username
          CRIO_VERSION       = var.crio_version
          KUBERNETES_VERSION = var.kubernetes_version
        }))
        os_disk = {
          name                 = "linuxVmWorkerDisk13"
          caching              = "ReadWrite"
          storage_account_type = "StandardSSD_LRS"
          disk_size_gb         = 64
        }
      }
    }
  }

  network = {
    virtual_network = {
      address_space = ["10.240.0.0/16"]
      name          = "k8s-${var.environment}-vnet"
      subnet = {
        k8s = {
          address_prefixes = ["10.240.0.0/16"]
          name             = "k8sNodesSubnet"
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
      resources = jsonencode({
        "com.cloudflare.api.account.zone.${local.decoded_vault_yaml.cloudflare.zone_id}" = "*"
      })
    }
  ]

  azure_csi_driver = {
    wait             = true
    wait_for_jobs    = false
    create_namespace = false
    version          = "1.34.1"
    namespace        = var.kubeNamespace
    name             = "azuredisk-csi-driver"
    chart            = "azuredisk-csi-driver"
    repository       = "https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts"
    set = [
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

  istio = {
    base = {
      wait             = true
      wait_for_jobs    = false
      create_namespace = false
      chart            = "base"
      version          = "1.28.3"
      name             = "istio-base"
      namespace        = var.istioNamespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set = [
        {
          name  = "defaultRevision"
          value = "default"
        }
      ]
      values = []
    },
    discovery = {
      wait             = true
      wait_for_jobs    = true
      create_namespace = false
      chart            = "istiod"
      version          = "1.28.3"
      name             = "istio-discovery"
      namespace        = var.istioNamespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set              = []
      values = []
    },
    cni = {
      wait             = true
      create_namespace = false
      wait_for_jobs    = false
      chart            = "cni"
      version          = "1.28.3"
      name             = "istio-cni"
      namespace        = var.istioNamespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set = [
        {
          name  = "pilot.cni.enabled"
          value = "true"
        }
      ]
      values = []
    },
    gateway = {
      wait_for_jobs    = true
      wait             = false
      create_namespace = false
      version          = "1.28.3"
      chart            = "gateway"
      namespace        = var.istioNamespace
      name             = "istio-ingressgateway"
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set = [
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
          zones       = "www.${var.zone},${var.zone}"
          externalIPs = [module.project_nodes_public_ips["haProxyLB"].ip_address]
        })
      ]
    }
  }

  self-hosted-ai = {
    ollama = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "1.42.0"
      name             = "ollama"
      chart            = "ollama"
      namespace        = var.openWebuiNamespace
      repository       = "https://helm.otwld.com/"
      set              = []
      values = [
        templatefile("${path.module}/helmOllamaValues/values.yaml.tpl", {
          numberOfReplicas            = var.ollamaNumberOfReplicas
          ollamaStorageClass          = var.managedDisks["ollama"].storage_class_name
          ollamaVolumeName            = var.managedDisks["ollama"].persistent_volume_name
          ollamaPersistentVolumeClaim = var.managedDisks["ollama"].persistent_volume_claim
        })
      ]
    },
    open-webui = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "12.1.0"
      name             = "open-webui"
      chart            = "open-webui"
      namespace        = var.openWebuiNamespace
      repository       = "https://helm.openwebui.com/"
      set              = []
      values = [
        templatefile("${path.module}/helmOpenWebUiValues/values.yaml.tpl", {
          openWebuiNamespace = var.openWebuiNamespace
        })
      ]
    }
  }

  helm_prime_packages = {
    calico = {
      wait             = true
      create_namespace = true
      wait_for_jobs    = false
      version          = "3.31.3"
      name             = "projectcalico"
      chart            = "tigera-operator"
      namespace        = "tigera-operator"
      repository       = "https://docs.tigera.io/calico/charts"
      set              = []
      values = [
        templatefile("${path.module}/helmCalicoValues/values.yaml.tpl", {
          podNetworkCidr = var.podNetworkCidr
        })
      ]
    },
    cert-manager = {
      wait             = true
      wait_for_jobs    = true
      create_namespace = false
      version          = "1.19.3"
      name             = "cert-manager"
      chart            = "cert-manager"
      namespace        = var.certManagerNamespace
      repository       = "https://charts.jetstack.io"
      set = [
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
      version          = "3.13.0"
      name             = "metrics-server"
      chart            = "metrics-server"
      namespace        = var.kubeNamespace
      repository       = "https://kubernetes-sigs.github.io/metrics-server/"
      set              = []
      values = [
        file("${path.module}/metricsServer/values.yaml")
      ]
    }
  }

  helm_deployment = {
    alloy = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "1.6.0"
      name             = "alloy"
      chart            = "alloy"
      namespace        = var.monitoringNamespace
      repository       = var.monitoringHelmChartUrl
      set              = []
      values = [
        templatefile("${path.module}/helmAlloyValues/values.yaml.tpl", {
          loggingLevel    = "info"
          loggingFormat   = "logfmt"
          lokiEndpointUrl = "http://loki-gateway.${var.monitoringNamespace}.svc.cluster.local:80"
          tempoEndpoint   = "http://tempo-distributed-ingester.${var.monitoringNamespace}.svc.cluster.local:3200"
        })
      ]
    },
    # argo-cd = {
    #   create_namespace = true
    #   wait             = true
    #   wait_for_jobs    = false
    #   version          = "9.4.2"
    #   name             = "argo-cd"
    #   chart            = "argo-cd"
    #   namespace        = var0.argoCdNamespace
    #   repository       = "https://argoproj.github.io/argo-helm"
    #   set = [
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
    headlamp = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "0.40.0"
      name             = "headlamp"
      chart            = "headlamp"
      namespace        = var.kubeNamespace
      repository       = "https://kubernetes-sigs.github.io/headlamp/"
      set = [
        {
          name  = "replicaCount"
          value = var.headlampReplicaCount
        }
      ]
      values = [
        # templatefile("${path.module}/helmHeadlampValues/values.yaml.tpl", {
        # file("${path.module}/helmHeadlampValues/values.yaml")
        # replicaCount = var.headlampReplicaCount
        # })
      ]
    },
    grafana = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "10.5.15"
      name             = "grafana"
      chart            = "grafana"
      namespace        = var.monitoringNamespace
      repository       = var.monitoringHelmChartUrl
      set              = []
      values = [
        templatefile("${path.module}/helmGrafanaValues/values.yaml.tpl", {
          namespace        = var.monitoringNamespace
          defaultRegion    = module.project_resource_group.location
          adminPassword    = local.decoded_vault_yaml.monitoring.grafana.adminPassword
          storageClassName = local.persistentStorage.grafana.storageClass.metadata.name
          existingClaim    = local.persistentStorage.grafana.persistentVolumeClaim.metadata.name
          size             = local.persistentStorage.grafana.persistentVolume.spec.capacity.storage
          lokiUrl          = "http://loki-gateway.${var.monitoringNamespace}.svc.cluster.local:80"
          prometheusUrl    = "http://prometheus-server.${var.monitoringNamespace}.svc.cluster.local:80"
          tempoUrl         = "http://tempo-distributed-query-frontend.${var.monitoringNamespace}.svc.cluster.local:3200"
          config_labels = {
            "app.kubernetes.io/name"     = "grafana"
            "app.kubernetes.io/instance" = "grafana"
          }
        })
      ]
    },
    external-dns = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "1.20.0"
      name             = "external-dns"
      chart            = "external-dns"
      namespace        = var.certManagerNamespace
      repository       = "https://kubernetes-sigs.github.io/external-dns/"
      set              = []
      values = [
        templatefile("${path.module}/helmExternalDnsValues/cloudflare.yaml.tpl", {
          txtOwnerId                   = var.CLOUDFLARE_ZONE_ID
          cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
          cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name
        })
      ]
    },
    loki = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      name             = "loki"
      chart            = "loki"
      version          = "6.53.0"
      namespace        = var.monitoringNamespace
      repository       = var.monitoringHelmChartUrl
      set              = []
      values = [
        templatefile("${path.module}/helmLokiValues/values.yaml.tpl", {
          replicas          = var.lokiNumberOfReplicas
          account_name      = module.project_storage_account.name
          ruler             = local.storage_account_container.ruler.name
          admin             = local.storage_account_container.admin.name
          chunks            = local.storage_account_container.chunks.name
          account_key       = module.project_storage_account.primary_access_key
          connection_string = module.project_storage_account.primary_connection_string
        })
      ]
    },
    prometheus = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "28.9.1"
      name             = "prometheus"
      chart            = "prometheus"
      namespace        = var.monitoringNamespace
      repository       = "https://prometheus-community.github.io/helm-charts"
      set              = []
      values = [
        templatefile("${path.module}/helmPrometheusValues/values.yaml.tpl", {
          storageClass  = local.persistentStorage.prometheus_server.storageClass.metadata.name
          existingClaim = local.persistentStorage.prometheus_server.persistentVolumeClaim.metadata.name
          config_labels = {
            "app.kubernetes.io/name"      = "prometheus"
            "app.kubernetes.io/component" = "server"
            "app.kubernetes.io/instance"  = "prometheus"
          }
          scrapeConfigNodes = [
            local.master_nodes.master01.linux_virtual_machine.name,
            local.master_nodes.master02.linux_virtual_machine.name,
            local.master_nodes.master03.linux_virtual_machine.name,
            local.worker_nodes.worker01.linux_virtual_machine.name,
            local.worker_nodes.worker02.linux_virtual_machine.name,
            local.worker_nodes.worker03.linux_virtual_machine.name
          ]
        })
      ]
    },
    reflector = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "10.0.8"
      chart            = "reflector"
      name             = "emberstack"
      namespace        = var.kubeNamespace
      repository       = "https://emberstack.github.io/helm-charts"
      set              = []
      values           = []
    },
    sealed-secrets = {
      wait             = true
      recreate_pods    = true
      create_namespace = true
      wait_for_jobs    = false
      version          = "2.18.1"
      name             = "sealed-secrets"
      chart            = "sealed-secrets"
      namespace        = var.sealed_secrets_namespace
      repository       = "https://bitnami-labs.github.io/sealed-secrets"
      set              = []
      values           = []
    },
    tempo = {
      wait             = true
      recreate_pods    = true
      create_namespace = false
      wait_for_jobs    = false
      version          = "1.61.3"
      name             = "tempo-distributed"
      chart            = "tempo-distributed"
      namespace        = var.monitoringNamespace
      repository       = var.monitoringHelmChartUrl
      set              = []
      values = [
        templatefile("${path.module}/helmGrafanaTempoValues/values.yaml.tpl", {
          tempoSecretKeyRef          = var.tempoSecretKey
          tempoSecretKeyRefName      = var.tempoSecretName
          storageAccountName         = module.project_storage_account.name
          tempoContainerName         = local.storage_account_container.tempo.name
          STORAGE_ACCOUNT_ACCESS_KEY = module.project_storage_account.primary_access_key
        })
      ]
    }
  }

  knative = {
    operator = {
      filename = "${path.module}/roles/knative/files/operator.yaml"
      content  = replace(data.http.knative_operator.response_body, "initialDelaySeconds: 120", "initialDelaySeconds: 180")
    }
    net_istio = {
      filename = "${path.module}/roles/knative/files/net-istio.yaml"
      content  = data.http.net_istio.response_body
    }
  }

  istioGateway = {
    headlamp = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      gatewayTlsMode                               = "SIMPLE"
      component                                    = "headlamp"
      gatewaySelector                              = "ingressgateway"
      namespace                                    = var.kubeNamespace
      certificateNamespace                         = var.istioNamespace
      certificateIssuerRefName                     = var.issuer_name_prod
      hosts                                        = "headlamp.${var.zone}"
      commonName                                   = "headlamp.${var.zone}"
      gatewayName                                  = "istio-ingressgateway-headlamp"
      virtualServiceName                           = "istio-virtualservice-headlamp"
      secretName                                   = "headlamp-${var.issuer_name_prod}"
      virtualServiceGateways                       = "${var.kubeNamespace}/istio-ingressgateway-headlamp"
      virtualServiceHttpRouteDestinationHost       = "headlamp.${var.kubeNamespace}.svc.cluster.local"
    },
    grafana = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      # virtualServiceTask                           = "virtualService"
      gatewayTlsMode                         = "SIMPLE"
      component                              = "grafana"
      gatewaySelector                        = "ingressgateway"
      certificateNamespace                   = var.istioNamespace
      certificateIssuerRefName               = var.issuer_name_prod
      hosts                                  = "grafana.${var.zone}"
      commonName                             = "grafana.${var.zone}"
      namespace                              = var.monitoringNamespace
      gatewayName                            = "istio-ingressgateway-grafana"
      virtualServiceName                     = "istio-virtualservice-grafana"
      secretName                             = "grafana-${var.issuer_name_prod}"
      virtualServiceHttpRouteDestinationHost = "grafana.${var.monitoringNamespace}.svc.cluster.local"
      virtualServiceGateways                 = "${var.monitoringNamespace}/istio-ingressgateway-grafana"
    },
    openwebui = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      # virtualServiceTask                           = "virtualService"
      gatewayTlsMode                         = "SIMPLE"
      component                              = "openwebui"
      gatewaySelector                        = "ingressgateway"
      certificateNamespace                   = var.istioNamespace
      certificateIssuerRefName               = var.issuer_name_prod
      namespace                              = var.openWebuiNamespace
      hosts                                  = "openwebui.${var.zone}"
      commonName                             = "openwebui.${var.zone}"
      gatewayName                            = "istio-ingressgateway-openwebui"
      virtualServiceName                     = "istio-virtualservice-openwebui"
      secretName                             = "openwebui-${var.issuer_name_prod}"
      virtualServiceHttpRouteDestinationHost = "open-webui.${var.openWebuiNamespace}.svc.cluster.local"
      virtualServiceGateways                 = "${var.openWebuiNamespace}/istio-ingressgateway-openwebui"
    },
    prometheus = {
      virtualServiceHttpRouteDestinationPortNumber = 80
      virtualServiceHttpMatchUriPrefix             = "/"
      virtualServiceTask                           = "virtualService"
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
}

# User permissions
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
