# -- Number of replicas
replicaCount: ${numberOfReplicas}

# Docker image
image:
  # -- Docker image registry
  repository: ollama/ollama
    # -- Docker pull policy
  pullPolicy: IfNotPresent
  # -- Docker image tag, overrides the image tag whose default is the chart appVersion.
  tag: ""

# kubectl create secret docker-registry my-registry-secret \
#  --docker-server=<your-registry-server> \
#  --docker-username=<your-username> \
#  --docker-password=<your-password> \
#  --docker-email=<your-email>

# -- Docker registry secret names as an array
imagePullSecrets: []
  # example of imagePullSecrets
  # imagePullSecrets:
  # - name: my-registry-secret

ollama:
  gpu:
    # -- Enable GPU integration
    enabled: false

    # -- GPU type: 'nvidia' or 'amd'
    # type: 'nvidia'

    # -- Specify the number of GPU to 1
    # number: 1

  # -- List of models to pull at container startup
  models:
    pull:
      - llama3
    run:
      - llama3

persistentVolume:
  enabled: true
  volumeName: ${ollamaVolumeName}
  storageClass: ${ollamaStorageClass}
  existingClaim: ${ollamaPersistentVolumeClaim}
