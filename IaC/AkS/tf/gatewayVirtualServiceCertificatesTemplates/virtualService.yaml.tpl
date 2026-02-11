apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: ${virtualServiceName}
  labels:
    %{ for labels_key, labels_value in labels }
    ${labels_key}: ${labels_value}
    %{ endfor ~} # Labels to help with more information
  namespace: ${virtualServiceNamespace}
spec:
  hosts:
    %{ for host in hosts ~}
    - ${host}
    %{ endfor ~} # This should match a DNS name in the Certificate
  gateways:
    %{ for virtualServiceGateway in virtualServiceGateways ~}
    - ${virtualServiceGateway}
    %{ endfor ~} # This should match a DNS name in the Certificate
  http:
    - match:
        - uri:
            prefix: '${virtualServiceHttpMatchUriPrefix}'
      route:
        - destination:
            host: ${virtualServiceHttpRouteDestinationHost}
            port:
              number: ${virtualServiceHttpRouteDestinationPortNumber}