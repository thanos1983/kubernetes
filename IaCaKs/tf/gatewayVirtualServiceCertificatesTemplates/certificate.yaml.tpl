apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${secretName}
  labels:
    %{ for labels_key, labels_value in labels }
    ${labels_key}: ${labels_value}
    %{ endfor ~} # Labels to help with more information
  namespace: ${certificateNamespace}
spec:
  secretName: ${secretName}
  commonName: ${commonName}
  dnsNames:
    %{ for h in hosts ~}
    - ${h}
    %{ endfor ~} # This should match a DNS name in the Certificate
  issuerRef:
    kind: Issuer
    name: ${certificateIssuerRefName}