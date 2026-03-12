replicaCount: ${replicaCount}

pluginsManager:
  enabled: true
  baseImage: node:lts-alpine  # Required for building plugins
  version: latest
  configContent: |
    plugins:
      - name: headlamp-ai
        source: https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_ai_assistant
        version: 0.1.0-alpha
      - name: headlamp-kubescape
        source: https://artifacthub.io/packages/headlamp/kubescape-headlamp-plugin/headlamp_kubescape
        version: 0.10.5
      - name: headlamp-cert-manager
        source: https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_cert-manager
        version: 0.1.0
      - name: headlamp-knative
        source: https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_knative
        version: 0.1.0-alpha
    installOptions:
      parallel: true
      maxConcurrent: 2

config:
  watchPlugins: true # Set to true to enable automatic plugin updates in main headlamp container
