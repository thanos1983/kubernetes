vmselect:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8481"
  persistentVolume:
    enabled: true
    existingClaim: ""
  serviceMonitor:
    namespace: "${monitoringNamespace}"

vminsert:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8480"
  persistentVolume:
    enabled: true
    existingClaim: "${vmInsertExistingClaim}"
  serviceMonitor:
    namespace: "${monitoringNamespace}"

vmstorage:
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8482"
  serviceMonitor:
    namespace: "${monitoringNamespace}"
