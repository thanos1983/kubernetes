loki:
  # Should authentication be enabled
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

  storage:
    type: azure
    azure:
      # Name of the Azure Blob Storage account
      accountName: "${account_name}"
      # Key associated with the Azure Blob Storage account
      accountKey: "${account_key}"
      # Comprehensive connection string for Azure Blob Storage account (Can be used to replace endpoint, accountName, and accountKey)
      # connectionString: <your-connection-string>
      # Flag indicating whether to use Azure Managed Identity for authentication
      useManagedIdentity: false
      # Flag indicating whether to use a federated token for authentication
      useFederatedToken: false
      # Client ID of the user-assigned managed identity (if applicable)
      # userAssignedId: <your-user-assigned-id>
      # Timeout duration for requests made to the Azure Blob Storage account (in seconds)
      requestTimeout: 0
      # Domain suffix of the Azure Blob Storage service endpoint (e.g., core.windows.net)
      endpoint_suffix: blob.core.windows.net
    bucketNames:
      ruler: "${ruler}"
      admin: "${admin}"
      chunks: "${chunks}"
    object_store:
      azure:
        # Storage account name
        account_name: "${account_name}"
        # Optional storage account key
        account_key: "${account_key}"

# Disable minio storage
minio:
  enabled: false

deploymentMode: SimpleScalable

# Zero out replica counts of other deployment modes
backend:
  replicas: ${replicas}
read:
  replicas: ${replicas}
write:
  replicas: ${replicas}

ingester:
  replicas: 0
querier:
  replicas: 0
queryFrontend:
  replicas: 0
queryScheduler:
  replicas: 0
distributor:
  replicas: 0
compactor:
  replicas: 0
indexGateway:
  replicas: 0
bloomCompactor:
  replicas: 0
bloomGateway:
  replicas: 0
