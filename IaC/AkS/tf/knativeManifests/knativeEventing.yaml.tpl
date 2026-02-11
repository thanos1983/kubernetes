apiVersion: v1
kind: Namespace
metadata:
  name: ${knativeEventingName}
  labels:
    istio-injection: enabled
---
apiVersion: operator.knative.dev/v1beta1
kind: KnativeEventing
metadata:
  name: ${knativeEventingName}
  namespace: ${knativeEventingNamespace}