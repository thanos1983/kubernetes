image:
  repository: "otel/opentelemetry-collector-k8s"

mode: "${mode}"

presets:
  logsCollection:
    enabled: true
    includeCollectorLogs: true
  kubernetesAttributes:
    enabled: true
  hostMetrics:
    enabled: true
  kubeletMetrics:
    enabled: true
