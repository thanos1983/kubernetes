controller:
  service:
    annotations:
      external-dns.alpha.kubernetes.io/hostname: ${zones}
    externalTrafficPolicy: "Local"
    externalIPs:
%{ for externalIP in externalIPs ~}
      - ${externalIP}
%{ endfor ~}
  metrics:
    enabled: true
  podAnnotations:
    prometheus.io/port: "10254"
    prometheus.io/scrape: "true"
