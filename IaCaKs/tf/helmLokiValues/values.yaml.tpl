loki:
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: azure
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  storage_config:
    azure:
      account_name: "${STORAGE_ACCOUNT_NAME}"
      container_name: "${STORAGE_ACCOUNT_CONTAINER_CHUNKS}" # Your actual Azure Blob Storage container name (loki-azure-dev-chunks)
  ingester:
    chunk_encoding: snappy
  pattern_ingester:
    enabled: true
  limits_config:
    allow_structured_metadata: true
    volume_enabled: true
    retention_period: 672h # 28 days retention
  compactor:
    retention_enabled: true
    delete_request_store: azure
  ruler:
    enable_api: true
    storage:
      type: azure
      azure:
        account_name: ${STORAGE_ACCOUNT_NAME}
        container_name: ${STORAGE_ACCOUNT_CONTAINER_RULER} # Your actual Azure Blob Storage container name (loki-azure-dev-ruler)
      alertmanager_url: ${PROMETHEUS_ALERT_URL} # The URL of the Alertmanager to send alerts (Prometheus, Mimir, etc.)

  querier:
    max_concurrent: 4

  storage:
    object_store:
      azure:
        accountKey: ${STORAGE_ACCOUNT_KEY}
        accountName: ${STORAGE_ACCOUNT_NAME}
    type: azure
    bucketNames:
      chunks: "${STORAGE_ACCOUNT_CONTAINER_CHUNKS}" # Your actual Azure Blob Storage container name (loki-azure-dev-chunks)
      ruler: "${STORAGE_ACCOUNT_CONTAINER_RULER}" # Your actual Azure Blob Storage container name (loki-azure-dev-ruler)
      admin: "${STORAGE_ACCOUNT_CONTAINER_ADMIN}" # Your actual Azure Blob Storage container name (loki-azure-dev-admin)
    azure:
      accountKey: ${STORAGE_ACCOUNT_KEY}
      requestTimeout: ${REQUEST_TIMEOUT}
      accountName: ${STORAGE_ACCOUNT_NAME}
      connectionString: ${STORAGE_ACCOUNT_CONNECTION_STRING}

deploymentMode: Distributed

ingester:
  replicas: 3
  zoneAwareReplication:
    enabled: false

querier:
  replicas: 3
  maxUnavailable: 2

queryFrontend:
  replicas: 2
  maxUnavailable: 1

queryScheduler:
  replicas: 2

distributor:
  replicas: 3
  maxUnavailable: 2
compactor:
  replicas: 1

indexGateway:
  replicas: 2
  maxUnavailable: 1

ruler:
  replicas: 1
  maxUnavailable: 1

backend:
  replicas: 0
read:
  replicas: 0
write:
  replicas: 0

singleBinary:
  replicas: 0
