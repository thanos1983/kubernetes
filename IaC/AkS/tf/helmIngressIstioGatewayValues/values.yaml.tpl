service:
  externalTrafficPolicy: "Local"
  annotations:
    external-dns.alpha.kubernetes.io/ttl: "120"
    external-dns.alpha.kubernetes.io/hostname: "${zone}"
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: "/healthz"
