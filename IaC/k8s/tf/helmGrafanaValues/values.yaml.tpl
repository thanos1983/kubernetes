adminUser: admin
adminPassword: ${adminPassword}

serviceMonitor:
  enabled: false
  namespace: ${namespace}

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: ${prometheusUrl}
        access: proxy
        isDefault: true
        editable: false
        jsonData:
          authType: default
          tlsAuth: false
          tlsAuthWithCACert: false
          tlsSkipVerify: false

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
      - name: 'istio'
        orgId: 1
        folder: 'default'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/istio
      - name: 'prometheus'
        orgId: 1
        folder: 'default'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/prometheus

dashboards:
  istio:
    imported-dashboard-name:
      gnetId: 7645
      revision: 225
      datasource: Prometheus
      # https://grafana.com/grafana/dashboards/7639-istio-mesh-dashboard/
  prometheus:
    imported-dashboard-name:
      gnetId: 315
      revision: 3
      datasource: Prometheus
      # https://grafana.com/grafana/dashboards/315-kubernetes-cluster-monitoring-via-prometheus/

initChownData:
  enabled: false

persistence:
  type: pvc
  enabled: true
  existingClaim: ${existingClaim}
  storageClassName: ${storageClass}
  accessModes:
    - ReadWriteOnce
  size: ${size}
  selectorLabels:
%{ for config_label_key, config_label_value in config_labels ~}
      ${config_label_key}: ${config_label_value}
%{ endfor ~}
  finalizers:
    - kubernetes.io/pvc-protection