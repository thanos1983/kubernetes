storage:
  trace:
    backend: azure
    azure:
      storage_account_name: ${STORAGE_ACCOUNT_NAME}
      container_name: ${STORAGE_ACCOUNT_CONTAINER_NAME}
      storage_account_key: $${STORAGE_ACCOUNT_ACCESS_KEY}

traces:
  otlp:
    http:
      enabled: true
      # -- HTTP receiver advanced config
      receiverConfig: {}
      # -- Default OTLP http port
      port: 4318
    grpc:
      enabled: true
      # -- GRPC receiver advanced config
      receiverConfig: {}
      # -- Default OTLP gRPC port
      port: 4317

distributor:
  config:
    log_received_spans:
      enabled: true
    log_discarded_spans:
      enabled: true
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}

compactor:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}

ingester:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}

querier:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}

queryFrontend:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}

generator:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${TEMPO_TRACES_STG_KEY}
          key: ${TEMPO_TRACES_KEY}
