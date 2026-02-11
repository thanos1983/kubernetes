replicaCount: 1

env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        key: ${cloudflare_secretKeyRef_key}
        name: ${cloudflare_secretKeyRef_name}
