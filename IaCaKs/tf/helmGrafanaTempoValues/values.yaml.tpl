storage:
  trace:
    backend: azure
    azure:
      storage_account_name: ${STORAGE_ACCOUNT_NAME}
      container_name: ${STORAGE_ACCOUNT_CONTAINER_NAME}
      storage_account_key: $${STORAGE_ACCOUNT_ACCESS_KEY}

distributor:
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
