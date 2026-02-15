service:
  ports:
    - name: status-port
      port: 15021
      nodePort: 30021
      protocol: TCP
      targetPort: 15021
    - name: http2
      port: 80
      nodePort: 30080
      protocol: TCP
      targetPort: 80
    - name: https
      port: 443
      nodePort: 30443
      protocol: TCP
      targetPort: 443
  externalTrafficPolicy: "Local"
  externalIPs:
%{ for externalIP in externalIPs ~}
    - ${externalIP}
%{ endfor ~}
  annotations:
    external-dns.alpha.kubernetes.io/ttl: "120"
    external-dns.alpha.kubernetes.io/hostname: "${zones}"
    service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: "/healthz"
