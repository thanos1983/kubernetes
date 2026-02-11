apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${certificate_metadata_name}
  namespace: ${certificate_metadata_namespace}
spec:
  issuerRef:
    kind: Issuer
    name: ${cluster_issuer_name}
  secretName: ${secretKeyRef_name}
  dnsNames:
    - ${certificate_spec_dnsName}
  privateKey:
    algorithm: RSA
    encoding: PKCS1
    size: 4096
  isCA: false
  usages:
    - server auth
    - client auth