metricsGenerator:
  enabled: false
  replicas: 1

tempo:
  registry: docker.io
  repository: grafana/tempo
  tag: null
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ##
  # pullSecrets:
  #   - myRegistryKeySecretName

storage:
  trace:
    backend: azure
    blocklist_poll_tenant_index_builders: 1
    blocklist_poll_jitter_ms: 500
    azure:
      container_name: ${tempoContainerName}
      storage_account_name: ${storageAccountName}
      storage_account_key: ${STORAGE_ACCOUNT_ACCESS_KEY}

distributor:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${tempoSecretKeyRefName}
          key: ${tempoSecretKeyRef}

compactor:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${tempoSecretKeyRefName}
          key: ${tempoSecretKeyRef}

ingester:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${tempoSecretKeyRefName}
          key: ${tempoSecretKeyRef}

querier:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${tempoSecretKeyRefName}
          key: ${tempoSecretKeyRef}

queryFrontend:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
          name: ${tempoSecretKeyRefName}
          key: ${tempoSecretKeyRef}

generator:
  extraArgs:
    - "-config.expand-env=true"
  extraEnv:
    - name: STORAGE_ACCOUNT_ACCESS_KEY
      valueFrom:
        secretKeyRef:
            name: ${tempoSecretKeyRefName}
            key: ${tempoSecretKeyRef}

traces:
  otlp:
    http:
      enabled: true
    grpc:
      enabled: true

#persistence:
#  enabled: false
#  # -- Enable StatefulSetAutoDeletePVC feature
#  enableStatefulSetAutoDeletePVC: false
#  # storageClassName: local-path
#  accessModes:
#    - ReadWriteOnce
#  size: 10Gi
