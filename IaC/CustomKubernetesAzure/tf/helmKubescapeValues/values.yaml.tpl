alertCRD:
  installDefault: ${installDefault}

nodeAgent:
  config:
    maxLearningPeriod: "${maxLearningPeriod}"

capabilities:
  continuousScan: ${continuousScan}
  runtimeDetection: ${runtimeDetection}
  networkPolicyService: ${networkPolicyService}

persistence:
  storageClass: "${storageClass}"
