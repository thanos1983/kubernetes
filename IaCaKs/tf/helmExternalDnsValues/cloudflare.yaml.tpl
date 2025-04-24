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
        name: ${cloudflare_secretKeyRef_name}
        key: ${cloudflare_secretKeyRef_key}