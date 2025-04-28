apiVersion: v1
kind: Namespace
metadata:
  name: ${istioNamespace}
  labels:
    name: ${istioNamespace}
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${certManagerNamespace}
  labels:
    name: ${certManagerNamespace}
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${faasNamespace}
  labels:
    name: ${faasNamespace}
    istio-injection: "enabled"
