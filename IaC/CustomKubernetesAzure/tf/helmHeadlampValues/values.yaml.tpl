replicaCount: ${replicaCount}

pluginsManager:
  enabled: true
  configContent: |
    plugins:
      - name: ai-assistant
        source: https://artifacthub.io/packages/headlamp/headlamp-plugins/headlamp_ai_assistant
        version: 0.1.0-alpha
    installOptions:
      parallel: true
      maxConcurrent: 2
  baseImage: node:lts-alpine
  version: latest

config:
  watchPlugins: true  # Set to true to enable automatic plugin updates in main headlamp container
