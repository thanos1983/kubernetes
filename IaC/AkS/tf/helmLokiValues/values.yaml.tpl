loki:
  auth_enabled: false
  schemaConfig:
    configs:
      - from: "2024-04-01"
        store: tsdb
        object_store: azure
        schema: v13
        index:
          prefix: loki_index_
          period: 24h
  ingester:
    chunk_encoding: snappy
  tracing:
    enabled: true
  querier:
    max_concurrent: 4

  storage:
    type: azure
    azure:
      # Name of the Azure Blob Storage account
      accountName: "${STORAGE_ACCOUNT_NAME}"
      # Key associated with the Azure Blob Storage account
      accountKey: ${STORAGE_ACCOUNT_KEY}
      # Comprehensive connection string for Azure Blob Storage account (Can be used to replace endpoint, accountName, and accountKey)
      connectionString: ${STORAGE_ACCOUNT_CONNECTION_STRING}
      # Flag indicating whether to use Azure Managed Identity for authentication
      useManagedIdentity: false
      # Flag indicating whether to use a federated token for authentication
      useFederatedToken: false
      # Client ID of the user-assigned managed identity (if applicable)
      userAssignedId: <YOUR_USER_ASSIGNED_ID>
      # Timeout duration for requests made to the Azure Blob Storage account (in seconds)
      requestTimeout: ${REQUEST_TIMEOUT}
      # Domain suffix of the Azure Blob Storage service endpoint (e.g., core.windows.net)
      endpointSuffix: <YOUR_ENDPOINT_SUFFIX>
    bucketNames:
      ruler: ${STORAGE_ACCOUNT_CONTAINER_RULER}
      admin: "${STORAGE_ACCOUNT_CONTAINER_ADMIN}"
      chunks: "${STORAGE_ACCOUNT_CONTAINER_CHUNKS}"

deploymentMode: SimpleScalable

backend:
  replicas: 3
read:
  replicas: 3
write:
  replicas: 3

# Disable minio storage
minio:
  enabled: false

gateway:
  autoscaling:
    enabled: true
