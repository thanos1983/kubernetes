provider:
  name: cloudflare
sources:
  - service
  - ingress
  - istio-gateway
  - istio-virtualservice
env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        key: ${cloudflare_secretKeyRef_key}
        name: ${cloudflare_secretKeyRef_name}
