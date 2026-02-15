apiVersion: v1
kind: Namespace
metadata:
  name: ${knativeServingName}
  labels:
    istio-injection: enabled
---
apiVersion: operator.knative.dev/v1beta1
kind: KnativeServing
metadata:
  name: ${knativeServingName}
  namespace: ${knativeServingNamespace}
spec:
  ingress:
    istio:
      enabled: true
      knative-ingress-gateway:
        selector:
          istio: ingressgateway
  config:
    domain:
      "${domain}": ""