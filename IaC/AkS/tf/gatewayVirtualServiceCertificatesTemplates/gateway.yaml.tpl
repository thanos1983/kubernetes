apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: ${gatewayName}
  labels:
    %{ for labels_key, labels_value in labels }
    ${labels_key}: ${labels_value}
    %{ endfor ~} # Labels to help with more information
  namespace: ${gatewayNamespace}
spec:
  selector:
    istio: ${gatewaySelector}
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        %{ for host in hosts ~}
        - ${host}
        %{ endfor ~} # This should match a DNS name in the Certificate
      tls:
        httpsRedirect: true
    - port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: ${gatewayTlsMode}
        credentialName: ${secretName} # This should match the Certificate secretName
      hosts:
        %{ for host in hosts ~}
        - ${host}
        %{ endfor ~} # This should match a DNS name in the Certificate