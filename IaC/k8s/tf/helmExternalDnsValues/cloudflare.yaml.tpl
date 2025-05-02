policy: sync
txtOwnerId: ${txtOwnerId}
provider:
  name: cloudflare
env:
  - name: CF_API_TOKEN
    valueFrom:
      secretKeyRef:
        name: ${cloudflare_secretKeyRef_name}
        key: ${cloudflare_secretKeyRef_key}
