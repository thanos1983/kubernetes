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
    installOptions:
      parallel: true
      maxConcurrent: 2

config:
  watchPlugins: true # Set to true to enable automatic plugin updates in main headlamp container
