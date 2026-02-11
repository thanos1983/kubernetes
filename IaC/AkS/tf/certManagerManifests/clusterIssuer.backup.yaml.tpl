apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${cluster_issuer_name}
  namespace: ${cluster_issuer_namespace}
spec:
  acme:
    email: ${acme_email}
    server: ${acme_server}
    privateKeySecretRef:
      name: ${secret_key_ref}
    solvers:
      - http01:
          ingress:
            serviceType: ClusterIP
            class: ${ingressClass}
            podTemplate:
              spec:
                nodeSelector:
                  "kubernetes.io/os": linux