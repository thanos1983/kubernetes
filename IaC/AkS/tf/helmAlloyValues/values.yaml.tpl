configReloader:
  securityContext:
    # this is the UID of the "nobody" user that the configReloader image runs as
    runAsUser: 65534
    runAsGroup: 65534

alloy:
  extraPorts:
    - name: otlp-grpc
      port: 4317
      targetPort: 4317
      protocol: TCP
    - name: otlp-http
      port: 4318
      targetPort: 4318
      protocol: TCP
  securityContext:
    runAsUser: 473
    runAsGroup: 473
  configMap:
    create: true
    content: |-
      logging {
        level = "${loggingLevel}"
        format = "${loggingFormat}"
      }

      // writing
      loki.write "k8s_cluster" {
        endpoint {
          url = "${lokiEndpointUrl}/loki/api/v1/push"
        }
      }

      // local.file_match discovers files on the local filesystem using glob patterns and the doublestar library.
      // It returns an array of file paths.
      local.file_match "node_logs" {
        path_targets = [{
            // Monitor syslog to scrape node-logs
            __path__  = "/var/log/syslog",
            job       = "node/syslog",
            node_name = sys.env("HOSTNAME"),
            cluster   = "${environment}",
        }]
      }

      // loki.source.file reads log entries from files and forwards them to other loki.* components.
      // You can specify multiple loki.source.file components by giving them different labels.
      loki.source.file "node_logs" {
        targets    = local.file_match.node_logs.targets
        forward_to = [loki.write.k8s_cluster.receiver]
      }

      // discovery.kubernetes allows you to find scrape targets from Kubernetes resources.
      // It watches cluster state and ensures targets are continually synced with what is currently running in your cluster.
      discovery.kubernetes "pod" {
        role = "pod"
        // Restrict to pods on the node to reduce cpu & memory usage
        selectors {
            role = "pod"
            field = "spec.nodeName=" + coalesce(sys.env("HOSTNAME"), constants.hostname)
        }
      }

      // discovery.relabel rewrites the label set of the input targets by applying one or more relabeling rules.
      // If no rules are defined, then the input targets are exported as-is.
      discovery.relabel "pod_logs" {
        targets = discovery.kubernetes.pod.targets

        // Label creation - "namespace" field from "__meta_kubernetes_namespace"
        rule {
          source_labels = ["__meta_kubernetes_namespace"]
          action = "replace"
          target_label = "namespace"
        }

        // Label creation - "pod" field from "__meta_kubernetes_pod_name"
        rule {
          source_labels = ["__meta_kubernetes_pod_name"]
          action = "replace"
          target_label = "pod"
        }

        // Label creation - "container" field from "__meta_kubernetes_pod_container_name"
        rule {
          source_labels = ["__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "container"
        }

        // Label creation -  "app" field from "__meta_kubernetes_pod_label_app_kubernetes_io_name"
        rule {
          source_labels = ["__meta_kubernetes_pod_label_app_kubernetes_io_name"]
          action = "replace"
          target_label = "app"
        }

        // Label creation -  "job" field from "__meta_kubernetes_namespace" and "__meta_kubernetes_pod_container_name"
        // Concatenate values __meta_kubernetes_namespace/__meta_kubernetes_pod_container_name
        rule {
          source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "job"
          separator = "/"
          replacement = "$1"
        }

        // Label creation - "__path__" field from "__meta_kubernetes_pod_uid" and "__meta_kubernetes_pod_container_name"
        // Concatenate values __meta_kubernetes_pod_uid/__meta_kubernetes_pod_container_name.log
        rule {
          source_labels = ["__meta_kubernetes_pod_uid", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "__path__"
          separator = "/"
          replacement = "/var/log/pods/*$1/*.log"
        }

        // Label creation -  "container_runtime" field from "__meta_kubernetes_pod_container_id"
        rule {
          source_labels = ["__meta_kubernetes_pod_container_id"]
          action = "replace"
          target_label = "container_runtime"
          regex = "^(\\S+):\\/\\/.+$"
          replacement = "$1"
        }
      }

      // loki.source.kubernetes tails logs from Kubernetes containers using the Kubernetes API.
      loki.source.kubernetes "pod_logs" {
        targets    = discovery.relabel.pod_logs.output
        forward_to = [loki.process.pod_logs.receiver]
      }

      // loki.process receives log entries from other Loki components, applies one or more processing stages,
      // and forwards the results to the list of receivers in the component's arguments.
      loki.process "pod_logs" {
        stage.static_labels {
          values = {
            cluster = "${environment}",
          }
        }

        forward_to = [loki.write.k8s_cluster.receiver]
      }

      // loki.source.kubernetes_events tails events from the Kubernetes API and converts them
      // into log lines to forward to other Loki components.
      loki.source.kubernetes_events "cluster_events" {
        job_name   = "integrations/kubernetes/eventhandler"
        log_format = "logfmt"
        forward_to = [
          loki.process.cluster_events.receiver,
        ]
      }

      // loki.process receives log entries from other loki components, applies one or more processing stages,
      // and forwards the results to the list of receivers in the component's arguments.
      loki.process "cluster_events" {
        stage.static_labels {
          values = {
            cluster = "${environment}",
          }
        }

        stage.labels {
          values = {
            kubernetes_cluster_events = "job",
          }
        }

        forward_to = [loki.write.k8s_cluster.receiver]
      }

      // Creates a receiver for OTLP gRPC.
      // You can easily add receivers for other protocols by using the correct component
      // from the reference list at: https://grafana.com/docs/alloy/latest/reference/components/
      otelcol.receiver.otlp "otlp_receiver" {
        grpc {
          endpoint = "0.0.0.0:4317"
        }

        http {
          endpoint = "0.0.0.0:4318"
        }

        output {
          traces = [otelcol.exporter.otlp.tempo.input]
        }
      }

      // Define an OTLP gRPC exporter to send all received traces to GET.
      // The unique label 'tempo' is added to uniquely identify this exporter.
      otelcol.exporter.otlp "tempo" {
        // Define the client for exporting.
        client {
          // Send to the locally running Tempo instance, on port 4317 (OTLP gRPC).
          endpoint = "${tempoEndpoint}"
          // Disable TLS for OTLP remote write.
          tls {
            // The connection is insecure.
            insecure = true
            // Do not verify TLS certificates when connecting.
            insecure_skip_verify = true
          }
        }
      }

      discovery.kubernetes "pods" {
        role = "pod"

        namespaces {
          own_namespace = false

          names = ["default"]
        }

        selectors {
          role  = "pod"
          label = "${environment}"
        }
      }

      prometheus.scrape "pods" {
        targets    = discovery.kubernetes.pods.targets
        forward_to = [prometheus.remote_write.default.receiver]
      }

      discovery.kubernetes "services" {
        role = "service"

        namespaces {
          own_namespace = false

          names = ["default"]
        }

        selectors {
          role  = "service"
          label = "${environment}"
        }
      }

      prometheus.scrape "services" {
        targets    = discovery.kubernetes.services.targets
        forward_to = [prometheus.remote_write.default.receiver]
      }

      prometheus.remote_write "default" {
        endpoint {
          url = "${prometheusEndpointUrl}/api/v1/write"
        }
      }

      tracing {
        sampling_fraction = 0.1
        write_to          = [otelcol.exporter.otlp.default.input]
      }

      otelcol.exporter.otlp "default" {
        client {
          endpoint = "tempo:4317"
        }
      }

      // istio proxy logs
      discovery.relabel "istio_proxy_logs" {
        targets = discovery.kubernetes.pods.targets

        rule {
            action        = "keep"
            source_labels = ["__meta_kubernetes_pod_container_name"]
            regex         = "istio-proxy.*"
        }
        rule {
            target_label = "job"
            replacement  = "integrations/istio"
        }
        rule {
            target_label  = "instance"
            source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_name"]
            separator     = "-"
        }
        rule {
            target_label  = "pod"
            action        = "replace"
            source_labels = ["__meta_kubernetes_pod_name"]
        }
      }

      loki.source.kubernetes "istio_proxy_logs" {
        targets    = discovery.relabel.istio_proxy_logs.output
        forward_to = [loki.process.istio_proxy_system_logs.receiver, loki.process.istio_proxy_access_logs.receiver]
      }

      loki.process "istio_proxy_system_logs" {
        forward_to = [loki.write.k8s_cluster.receiver]

        stage.drop {
            expression = "^\\[.*"
        }
        stage.multiline {
            firstline = "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}"
        }
        stage.regex {
            expression = "\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{6}Z\\t(?P<level>\\S+)\\t.+"
        }
        stage.labels {
            values = {
                level = "",
            }
        }
        stage.static_labels {
            values = {
                log_type = "system",
            }
        }
      }

      loki.process "istio_proxy_access_logs" {
        forward_to = [loki.write.k8s_cluster.receiver]

        stage.drop {
            expression = "^[^\\[].*"
        }
        stage.regex {
            expression = "\\[\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z\\] \"(?P<request_method>\\w+) \\S+ (?P<protocol>\\S+)\" (?P<response_code>\\d+) .+"
        }
        stage.labels {
            values = {
                request_method = "",
                protocol       = "",
                response_code  = "",
            }
        }
        stage.static_labels {
            values = {
                log_type = "access",
            }
        }
      }
