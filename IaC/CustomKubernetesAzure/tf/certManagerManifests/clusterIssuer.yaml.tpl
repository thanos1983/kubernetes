apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${cluster_issuer_name}
spec:
  acme:
    email: ${acme_email}
    server: ${acme_server}
    privateKeySecretRef:
      name: ${secret_key_ref}
    solvers:
      - dns01:
          cloudflare:
            email: ${acme_email}
            apiTokenSecretRef:
              name: ${cloudflare_secretKeyRef_name}
              key: ${cloudflare_secretKeyRef_key}
        selector:
          dnsZones:
            - '${domain}'