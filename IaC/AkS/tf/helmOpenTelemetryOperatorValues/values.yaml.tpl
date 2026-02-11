manager:
  collectorImage:
    repository: "otel/opentelemetry-collector-k8s"

admissionWebhooks:
  certManager:
    enabled: false
    issuerRef:
      kind: "${certManagerIssuerRefKind}"
      name: "${certManagerIssuerRefName}"
  autoGenerateCert:
    enabled: true
