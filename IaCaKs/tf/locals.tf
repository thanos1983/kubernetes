locals {
  # to be removed once the deployment is moved to a pipeline
  kube_config_path = "${path.module}/${var.kubeConfigFilename}"
  knativeDomain    = "knative.${var.zone}"

  cloudFlareTypeDnsRecord = {
    prime = {
      comment = "Primary record needed to trigger DNS resolution and subsequent."
      type    = "A"
      ttl     = var.ttl
      name    = "www.${var.zone}"
      content = module.aks_project_public_ips["aks"].ip_address
    }
    knative = {
      comment = "Primary record for Knative (subdomains) needed to trigger DNS resolution and subsequent."
      type    = "A"
      ttl     = var.ttl
      name    = "*.${local.knativeDomain}"
      content = module.aks_project_public_ips["aks"].ip_address
    }
  }

  aks_active_directory_admin_group = {
    admin-group = {
      description  = var.description_aad_group
      display_name = var.display_name_aad_group
      members = [
        data.azurerm_client_config.current.object_id
      ]
      owners = [
        data.azurerm_client_config.current.object_id
      ]
    }
  }

  aks_active_directory_groups = {
    "${var.demoNamespace}-dev" = {
      description  = "This group is meant to be used by the AAD users that will be assigned as Full Access users of the AKS cluster under Demo-Dev Namespace."
      display_name = "Full Access AAD group, for Demo-DEV Namespace."
      owners = [
        data.azurerm_client_config.current.object_id
      ]
      members = [
        data.azurerm_client_config.current.object_id
      ]
      namespaceRoles = {
        metadata_block = {
          name = "${var.demoNamespace}-dev-role"
        }
        rule_blocks = [
          {
            api_groups = ["", "extensions", "apps"]
            resources  = ["*"]
            verbs      = ["*"]
          },
          {
            api_groups = ["batch"]
            resources  = ["jobs", "cronjobs"]
            verbs      = ["*"]
          }
        ]
      }
    }
    "${var.demoNamespace}-sit" = {
      description  = "This group is meant to be used by the AAD users that will be assigned as Full Access users of the AKS cluster under Demo-Sit Namespace."
      display_name = "Full Access AAD group, for Demo-SIT Namespace."
      owners = [
        data.azurerm_client_config.current.object_id
      ]
      members = [
        data.azurerm_client_config.current.object_id
      ]
      namespaceRoles = {
        metadata_block = {
          name = "${var.demoNamespace}-sit-role"
        }
        rule_blocks = [
          {
            api_groups = ["", "extensions", "apps"]
            resources  = ["*"]
            verbs      = ["*"]
          },
          {
            api_groups = ["batch"]
            resources  = ["jobs", "cronjobs"]
            verbs      = ["*"]
          }
        ]
      }
    }
    "${var.demoNamespace}-uat" = {
      description  = "This group is meant to be used by the AAD users that will be assigned as Full Access users of the AKS cluster under Demo-Uat Namespace."
      display_name = "Full Access AAD group, for Demo-UAT Namespace."
      owners = [
        data.azurerm_client_config.current.object_id
      ]
      members = [
        data.azurerm_client_config.current.object_id
      ]
      namespaceRoles = {
        metadata_block = {
          name = "${var.demoNamespace}-uat-role"
        }
        rule_blocks = [
          {
            api_groups = ["", "extensions", "apps"]
            resources  = ["*"]
            verbs      = ["*"]
          },
          {
            api_groups = ["batch"]
            resources  = ["jobs", "cronjobs"]
            verbs      = ["*"]
          }
        ]
      }
    }
    "${var.demoNamespace}-prod" = {
      description  = "This group is meant to be used by the AAD users that will be assigned as Full Access users of the AKS cluster under Demo-Prod Namespace."
      display_name = "Full Access AAD group, for Demo-PROD Namespace."
      owners = [
        data.azurerm_client_config.current.object_id
      ]
      members = [
        data.azurerm_client_config.current.object_id
      ]
      namespaceRoles = {
        metadata_block = {
          name = "${var.demoNamespace}-prod-role"
        }
        rule_blocks = [
          {
            api_groups = ["", "extensions", "apps"]
            resources  = ["*"]
            verbs      = ["*"]
          },
          {
            api_groups = ["batch"]
            resources  = ["jobs", "cronjobs"]
            verbs      = ["*"]
          }
        ]
      }
    }
  }

  network = {
    virtual_network = {
      address_space = ["192.0.0.0/8"]
      name          = "${var.environment}vnet"
      subnets = {
        aks = {
          address_prefixes = ["192.168.0.0/16"]
          name             = "aksNodesSubnet"
        }
      }
    }
  }

  public_ips = {
    aks = {
      allocation_method = "Static"
      sku               = "Standard"
      name              = "${var.aks_cluster_name}-ip"
      # resource_group_name = module.aks_project_aks_cluster.node_resource_group
    }
  }

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
    # alloy = {
    #   wait             = true
    #   recreate_pods    = true
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "1.4.0"
    #   name             = "alloy"
    #   chart            = "alloy"
    #   namespace        = var.monitoring_namespace
    #   repository       = var.monitoringHelmChartUrl
    #   set              = []
    #   values = [
    #     templatefile("${path.module}/helmAlloyValues/values.yaml.tpl", {
    #       loggingLevel    = "info"
    #       loggingFormat   = "logfmt"
    #       lokiEndpointUrl = "http://loki-gateway.${var.monitoring_namespace}.svc.cluster.local:80"
    #       tempoEndpoint   = "http://tempo-distributed-ingester.${var.monitoring_namespace}.svc.cluster.local:3200"
    #     })
    #   ]
    # },
    # argo-cd = {
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "9.1.2"
    #   name             = "argo-cd"
    #   chart            = "argo-cd"
    #   namespace        = var.argoCdNamespace
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
    cert-manager = {
      wait_for_jobs    = false
      create_namespace = false
      version          = "1.19.1"
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
    external-dns = {
      create_namespace = false
      wait_for_jobs    = false
      version          = "1.19.0"
      name             = "external-dns"
      chart            = "external-dns"
      namespace        = var.certManagerNamespace
      repository       = "https://kubernetes-sigs.github.io/external-dns"
      set              = []
      values = [
        templatefile("${path.module}/helmExternalDnsValues/cloudflare.yaml.tpl", {
          # txtOwnerId                   = var.CLOUDFLARE_ZONE_ID # to be used with cloudflare.yaml.tpl.bck
          cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name,
          cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
        })
      ]
    },
    # grafana = {
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "10.1.4"
    #   name             = "grafana"
    #   chart            = "grafana"
    #   namespace        = var.monitoring_namespace
    #   repository       = var.monitoringHelmChartUrl
    #   set              = []
    #   values = [
    #     templatefile("${path.module}/helmGrafanaValues/values.yaml.tpl", {
    #       namespace     = var.monitoring_namespace
    #       adminPassword = var.MONITORING_BOOTSTRAP_PASSWORD
    #       lokiUrl       = "http://loki-gateway.${var.monitoring_namespace}.svc.cluster.local:80"
    #       prometheusUrl = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local:80"
    #     })
    #   ]
    # },
    # loki = {
    #   create_namespace = false
    #   wait_for_jobs    = false
    #   name             = "loki"
    #   chart            = "loki"
    #   version          = "6.46.0"
    #   namespace        = var.monitoring_namespace
    #   repository       = var.monitoringHelmChartUrl
    #   set              = []
    #   values = [
    #     templatefile("${path.module}/helmLokiValues/values.yaml.tpl", {
    #       requestTimeout   = "10s"
    #       accountName      = module.aks_project_storage_account.name
    #       accountKey       = module.aks_project_storage_account.primary_access_key
    #       connectionString = module.aks_project_storage_account.primary_connection_string
    #     })
    #   ]
    # },
    istio-base = {
      create_namespace = true
      wait_for_jobs    = false
      chart            = "base"
      version          = "1.28.0"
      name             = "istio-base"
      namespace        = var.istio_namespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set = [
        {
          name  = "defaultRevision"
          value = "default"
        }
      ]
      values = []
    },
    istio-cni = {
      create_namespace = true
      wait_for_jobs    = false
      chart            = "cni"
      version          = "1.28.0"
      name             = "istio-cni"
      namespace        = var.istio_namespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set              = []
      values           = []
    },
    istio-discovery = {
      create_namespace = true
      wait_for_jobs    = true
      chart            = "istiod"
      version          = "1.28.0"
      name             = "istio-discovery"
      namespace        = var.istio_namespace
      repository       = "https://istio-release.storage.googleapis.com/charts"
      set = [
        {
          name  = "meshConfig.accessLogFile"
          value = "/dev/stdout"
        }
      ]
      values = []
    },
    prometheus = {
      create_namespace = true
      wait_for_jobs    = false
      version          = "27.44.1"
      name             = "prometheus"
      chart            = "prometheus"
      namespace        = var.monitoring_namespace
      repository       = "https://prometheus-community.github.io/helm-charts"
      set              = []
      values = [
        file("${path.module}/helmPrometheusValues/values.yaml")
      ]
    },
    reflector = {
      create_namespace = false
      wait_for_jobs    = false
      version          = "9.1.37"
      chart            = "reflector"
      name             = "emberstack"
      namespace        = "kube-system"
      repository       = "https://emberstack.github.io/helm-charts"
      set              = []
      values           = []
    },
    sealed-secrets = {
      create_namespace = true
      wait_for_jobs    = false
      version          = "2.17.7"
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
      version          = "1.56.1"
      name             = "tempo-distributed"
      chart            = "tempo-distributed"
      namespace        = var.monitoring_namespace
      repository       = var.monitoringHelmChartUrl
      set              = []
      values = [
        templatefile("${path.module}/helmGrafanaTempoValues/values.yaml.tpl", {
          TEMPO_TRACES_KEY               = var.tempo_traces_key
          TEMPO_TRACES_STG_KEY           = var.tempo_traces_stg_key
          STORAGE_ACCOUNT_NAME           = module.aks_project_storage_account.name
          STORAGE_ACCOUNT_CONTAINER_NAME = module.aks_project_storage_account_container["tempo_container_name"].name
        })
      ]
    }
  }

  helm_deployment = {
    istio-gateway = {
      wait_for_jobs = true
      version       = "1.28.0"
      chart         = "gateway"
      namespace     = var.istio_namespace
      name          = "istio-ingressgateway"
      repository    = "https://istio-release.storage.googleapis.com/charts"
      set = [
        {
          name  = "replicaCount"
          value = var.ingressReplicaCount
        },
        {
          name  = "service.loadBalancerIP"
          value = module.aks_project_public_ips["aks"].ip_address
        }
      ]
      values = [
        templatefile("${path.module}/helmIngressIstioGatewayValues/values.yaml.tpl", {
          zone = var.zone
        })
      ]
    },
    # kiali = {
    #   create_namespace = true
    #   wait_for_jobs    = false
    #   version          = "2.7.1"
    #   name             = "kiali"
    #   chart            = "kiali-operator"
    #   namespace        = var.kialiNamespace
    #   repository       = "https://kiali.org/helm-charts"
    #   set = [
    #     {
    #       name  = "cr.create"
    #       value = "true"
    #     },
    #     {
    #       name  = "cr.create"
    #       value = "true"
    #     },
    #     {
    #       name  = "cr.namespace"
    #       value = var.istio_namespace
    #     },
    #     {
    #       name  = "cr.spec.auth.strategy"
    #       value = "anonymous"
    #     },
    #     {
    #       name  = "cr.spec.external_services.grafana.in_cluster_url"
    #       value = "http://grafana.${var.monitoring_namespace}.svc.cluster.local"
    #     },
    #     {
    #       name  = "cr.spec.external_services.prometheus.url"
    #       value = "http://prometheus-server.${var.monitoring_namespace}.svc.cluster.local"
    #     }
    #   ]
    #   values = []
    # }
  }

  istioGateway = {
    # argoCdGateway = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "argoCD"
    #       "app.kubernetes.io/name"      = "argoCdGateway"
    #       "app.kubernetes.io/instance"  = "argo-cd-terraform"
    #     }
    #     gatewayName      = "istio-ingressgateway-argo-cd"
    #     gatewayNamespace = var.argoCdNamespace
    #     gatewaySelector  = "ingressgateway"
    #     gatewayTlsMode   = "SIMPLE"
    #     secretName       = "argo-cd-${var.secret_key_ref}"
    #     hosts            = ["argo-cd.${var.zone}"]
    #   })
    # },
    # argoCdCertificate = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/certificate.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "argoCD"
    #       "app.kubernetes.io/instance"  = "argo-cd-terraform"
    #       "app.kubernetes.io/name"      = "argoCdCertificate"
    #     }
    #     secretName               = "argo-cd-${var.secret_key_ref}"
    #     certificateNamespace     = var.istio_namespace
    #     certificateIssuerRefName = var.issuer_name
    #     commonName               = "argo-cd.${var.zone}"
    #     hosts                    = ["argo-cd.${var.zone}"]
    #   })
    # },
    # argoCdVirtualService = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/virtualService.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "argoCD"
    #       "app.kubernetes.io/instance"  = "argo-cd-terraform"
    #       "app.kubernetes.io/name"      = "argoCdVirtualService"
    #     }
    #     virtualServiceName                           = "istio-virtualservice-argo-cd"
    #     virtualServiceNamespace                      = var.argoCdNamespace
    #     virtualServiceHttpMatchUriPrefix             = "/"
    #     virtualServiceHttpRouteDestinationHost       = "argo-cd-argocd-server.${var.argoCdNamespace}.svc.cluster.local"
    #     virtualServiceHttpRouteDestinationPortNumber = 443
    #     hosts                                        = ["argo-cd.${var.zone}"]
    #     virtualServiceGateways                       = ["${var.argoCdNamespace}/istio-ingressgateway-argo-cd"]
    #   })
    # },
    grafanaGateway = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "grafana"
          "app.kubernetes.io/name"      = "grafanaGateway"
          "app.kubernetes.io/instance"  = "grafana-terraform"
        }
        gatewayName      = "istio-ingressgateway-grafana"
        gatewayNamespace = var.monitoring_namespace
        gatewaySelector  = "ingressgateway"
        gatewayTlsMode   = "SIMPLE "
        secretName       = "grafana-${var.secret_key_ref}"
        hosts            = ["grafana.${var.zone}"]
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
        secretName               = "grafana-${var.secret_key_ref}"
        certificateNamespace     = var.istio_namespace
        certificateIssuerRefName = var.issuer_name
        commonName               = "grafana.${var.zone}"
        hosts                    = ["grafana.${var.zone}"]
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
        virtualServiceNamespace                      = var.monitoring_namespace
        virtualServiceHttpMatchUriPrefix             = "/"
        virtualServiceHttpRouteDestinationHost       = "grafana.${var.monitoring_namespace}.svc.cluster.local"
        virtualServiceHttpRouteDestinationPortNumber = 80
        hosts                                        = ["grafana.${var.zone}"]
        virtualServiceGateways                       = ["${var.monitoring_namespace}/istio-ingressgateway-grafana"]
      })
    },
    # kialiGateway = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "kiali"
    #       "app.kubernetes.io/name"      = "kialiGateway"
    #       "app.kubernetes.io/instance"  = "kiali-terraform"
    #     }
    #     gatewayName      = "istio-ingressgateway-kiali"
    #     gatewayNamespace = var.kialiNamespace
    #     gatewaySelector  = "ingressgateway"
    #     gatewayTlsMode   = "SIMPLE"
    #     secretName       = "kiali-${var.secret_key_ref}"
    #     hosts            = ["kiali.${var.zone}"]
    #   })
    # },
    # kialiCertificate = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/certificate.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "kiali"
    #       "app.kubernetes.io/instance"  = "kiali-terraform"
    #       "app.kubernetes.io/name"      = "kialiCertificate"
    #     }
    #     secretName               = "kiali-${var.secret_key_ref}"
    #     certificateNamespace     = var.istio_namespace
    #     certificateIssuerRefName = var.issuer_name
    #     commonName               = "kiali.${var.zone}"
    #     hosts                    = ["kiali.${var.zone}"]
    #   })
    # },
    # kialiVirtualService = {
    #   yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/virtualService.yaml.tpl", {
    #     labels = {
    #       "app.kubernetes.io/version"   = var.kubernetes_version
    #       "app.kubernetes.io/component" = "kiali"
    #       "app.kubernetes.io/instance"  = "kiali-terraform"
    #       "app.kubernetes.io/name"      = "kialiVirtualService"
    #     }
    #     virtualServiceName                           = "istio-virtualservice-argo-cd"
    #     virtualServiceNamespace                      = var.kialiNamespace
    #     virtualServiceHttpMatchUriPrefix             = "/"
    #     virtualServiceHttpRouteDestinationHost       = "kiali.${var.istio_namespace}.svc.cluster.local"
    #     virtualServiceHttpRouteDestinationPortNumber = 20001
    #     hosts                                        = ["kiali.${var.zone}"]
    #     virtualServiceGateways                       = ["${var.kialiNamespace}/istio-ingressgateway-kiali"]
    #   })
    # },
    prometheusGateway = {
      yaml_body = templatefile("${path.module}/gatewayVirtualServiceCertificatesTemplates/gateway.yaml.tpl", {
        labels = {
          "app.kubernetes.io/version"   = var.kubernetes_version
          "app.kubernetes.io/component" = "prometheus"
          "app.kubernetes.io/name"      = "prometheusGateway"
          "app.kubernetes.io/instance"  = "prometheus-terraform"
        }
        gatewayNamespace = var.monitoring_namespace
        gatewayName      = "istio-ingressgateway-prometheus"
        gatewaySelector  = "ingressgateway"
        gatewayTlsMode   = "SIMPLE "
        secretName       = "prometheus-${var.secret_key_ref}"
        hosts            = ["prometheus.${var.zone}"]
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
        secretName               = "prometheus-${var.secret_key_ref}"
        certificateNamespace     = var.istio_namespace
        certificateIssuerRefName = var.issuer_name
        commonName               = "prometheus.${var.zone}"
        hosts                    = ["prometheus.${var.zone}"]
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
        virtualServiceNamespace                      = var.monitoring_namespace
        virtualServiceHttpMatchUriPrefix             = "/"
        virtualServiceHttpRouteDestinationHost       = "prometheus-server.${var.monitoring_namespace}.svc.cluster.local"
        virtualServiceHttpRouteDestinationPortNumber = 80
        hosts                                        = ["prometheus.${var.zone}"]
        virtualServiceGateways                       = ["${var.monitoring_namespace}/istio-ingressgateway-prometheus"]
      })
    }
  }

  cert_manager_issuer_manifest = {
    ιssuer_prod = {
      yaml_body = templatefile("${path.module}/certManagerManifests/issuer.yaml.tpl", {
        domain                       = var.zone
        acme_server                  = var.acme_server
        issuer_name                  = var.issuer_name
        secret_key_ref               = var.secret_key_ref
        issuer_namespace             = var.istio_namespace
        acme_email                   = var.CLOUDFLARE_EMAIL
        cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
        cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name
      })
    },
    # issuer_stage = {
    #   yaml_body = templatefile("${path.module}/certManagerManifests/issuer.yaml.tpl", {
    #     acme_server                  = var.acme_server
    #     issuer_name                  = var.issuer_name
    #     secret_key_ref               = var.secret_key_ref
    #     issuer_namespace             = var.istio_namespace
    #     acme_email                   = var.CLOUDFLARE_EMAIL
    #     cloudflare_secretKeyRef_name = var.cloudflare_secretKeyRef_name
    #     cloudflare_secretKeyRef_key  = var.cloudflare_secretKeyRef_key
    #     domain                       = var.zone
    #   })
    # }
  }

  nameSpacesToCreate = {
    (var.certManagerNamespace) = {
      metadata = {
        name = var.certManagerNamespace
        labels = {
          istio-injection = "disabled"
        }
      }
    },
    (var.faasNamespace) = {
      metadata = {
        name = var.faasNamespace
        labels = {
          istio-injection = "enabled"
        }
      }
    },
    "${var.demoNamespace}-dev" = {
      metadata = {
        name = "${var.demoNamespace}-dev"
        labels = {
          istio-injection = "enabled"
        }
      }
    }
    "${var.demoNamespace}-sit" = {
      metadata = {
        name = "${var.demoNamespace}-sit"
        labels = {
          istio-injection = "enabled"
        }
      }
    }
    "${var.demoNamespace}-uat" = {
      metadata = {
        name = "${var.demoNamespace}-uat"
        labels = {
          istio-injection = "enabled"
        }
      }
    }
    "${var.demoNamespace}-prod" = {
      metadata = {
        name = "${var.demoNamespace}-prod"
        labels = {
          istio-injection = "enabled"
        }
      }
    }
    (var.monitoring_namespace) = {
      metadata = {
        name = var.monitoring_namespace
        labels = {
          istio-injection = "disabled"
        }
      }
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
}

data "azurerm_subscription" "subscription" {}

data "azurerm_client_config" "current" {}

data "http" "knative_operator" {
  url = "https://github.com/knative/operator/releases/download/knative-v${var.knativeOperatorVersion}/operator.yaml"
}

data "http" "net_istio" {
  url = "https://github.com/knative/net-istio/releases/download/knative-v${var.knativeNetIstioVersion}/net-istio.yaml"
}

# data "kubectl_file_documents" "knative_operator" {
#   content = replace(data.http.knative_operator.response_body, "initialDelaySeconds: 120", "initialDelaySeconds: 180")
# }

data "kubectl_file_documents" "net_istio" {
  content = data.http.net_istio.response_body
}

data "kubectl_file_documents" "knative_serving" {
  content = templatefile("${path.module}/knativeManifests/knativeServing.yaml.tpl", {
    knativeServingName      = var.knativeServingName
    knativeServingNamespace = var.knativeServingNamespace
    domain                  = local.knativeDomain
  })
}

data "kubectl_file_documents" "knative_eventing" {
  content = templatefile("${path.module}/knativeManifests/knativeEventing.yaml.tpl", {
    knativeEventingName      = var.knativeEventingName
    knativeEventingNamespace = var.knativeEventingNamespace
  })
}
