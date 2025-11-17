alloy:
  configMap:
    content: |-
      logging {
        level = "${loggingLevel}"
        format = "${loggingFormat}"
      }

      // events
      loki.source.kubernetes_events "events" {
        job_name   = "kubernetes-events"
        forward_to = [loki.process.events.receiver]
      }

      loki.process "events" {
        forward_to = [loki.write.in_cluster.receiver]

        stage.static_labels {
          values = {
            log_source = "kubernetes_events",
          }
        }
        stage.label_drop {
          values = [ "instance" ] // drop builtin alloy label. use job instead
        }

        stage.logfmt {
          mapping = {
            "extracted_reason" = "reason",
            "extracted_type" = "type",
            "extracted_kind" = "kind",
            "extracted_node" = "sourcehost",
            "extracted_node" = "reportinginstance",
            "extracted_component" = "sourcecomponent",
          }
        }

        stage.multiline {
            // firstline     = "^\\[\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2}:\\d{2}\\]"
            firstline     = "^\\d{4}-\\d{2}-\\d{2} \\d{1,2}:\\d{2}:\\d{2}"
            max_wait_time = "10s"
            max_lines     = 2048
        }

        stage.labels {
          values = {
            "reason" = "extracted_reason",
            "type" = "extracted_type",
            "kind" = "extracted_kind",
            "node" = "extracted_node",
            "component" = "extracted_component",
          }
        }
      }

      // Replace all values between the angle brackets '<>', with your desired configuration
      discovery.relabel "istio_proxy_metrics" {
        targets = discovery.kubernetes.pods.targets

        rule {
            action        = "keep"
            source_labels = ["__meta_kubernetes_pod_container_name"]
            regex         = "istio-proxy.*"
        }
        rule {
            source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            regex         = "(\\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})"
            target_label  = "__address__"
            replacement   = "[$2]:$1"
        }
        rule {
            source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            regex         = "(\\d+);((([0-9]+?)(\\.|$)){4})"
            target_label  = "__address__"
            replacement   = "$2:$1"
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

      prometheus.scrape "istio_proxy_metrics" {
        targets      = discovery.relabel.istio_proxy_metrics.output
        forward_to   = [prometheus.relabel.metrics_service.receiver]
        metrics_path = "/stats/prometheus"
      }

      discovery.relabel "istio_istiod_metrics" {
        targets = discovery.kubernetes.endpoints.targets

        rule {
            action        = "keep"
            source_labels = ["__meta_kubernetes_service_name", "__meta_kubernetes_endpoint_port_name"]
            regex         = "istiod;http-monitoring"
        }
        rule {
            source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            regex         = "(\\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})"
            target_label  = "__address__"
            replacement   = "[$2]:$1"
        }
        rule {
            source_labels = ["__meta_kubernetes_pod_annotation_prometheus_io_port", "__meta_kubernetes_pod_ip"]
            regex         = "(\\d+);((([0-9]+?)(\\.|$)){4})"
            target_label  = "__address__"
            replacement   = "$2:$1"
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

      prometheus.scrape "istio_istiod_metrics" {
        targets    = discovery.relabel.istio_istiod_metrics.output
        forward_to = [prometheus.relabel.metrics_service.receiver]
      }

      // Replace all values between the angle brackets '<>', with your desired configuration
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
        forward_to = [loki.process.logs_service.receiver]

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
                level  = "",
            }
        }
        stage.static_labels {
            values = {
                log_type = "system",
            }
        }
      }

      loki.process "istio_proxy_access_logs" {
        forward_to = [loki.process.logs_service.receiver]

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

      // pods
      discovery.kubernetes "pods" {
        role = "pod"
      }

      discovery.relabel "pods" {
        targets = discovery.kubernetes.pods.targets

        rule {
          source_labels = ["__meta_kubernetes_namespace"]
          action = "replace"
          target_label = "namespace"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_name"]
          action = "replace"
          target_label = "pod"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "container"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_label_app"]
          action = "replace"
          target_label = "app"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_controller_name"]
          target_label  = "controller_name"
          separator     = "/"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_controller_kind"]
          target_label  = "controller_kind"
          separator     = "/"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_node_name"]
          target_label  = "node"
          separator     = "/"
        }

        rule {
          source_labels = ["__meta_kubernetes_namespace", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "job"
          separator = "/"
          replacement = "$1"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_uid", "__meta_kubernetes_pod_container_name"]
          action = "replace"
          target_label = "__path__"
          separator = "/"
          replacement = "/var/log/pods/*$1/*.log"
        }

        rule {
          source_labels = ["__meta_kubernetes_pod_container_id"]
          action = "replace"
          target_label = "container_runtime"
          regex = "^(\\S+):\\/\\/.+$"
          replacement = "$1"
        }
      }

      loki.source.kubernetes "pods" {
        targets    = discovery.relabel.pods.output
        forward_to = [loki.process.pods.receiver]
      }

      loki.process "pods" {
        forward_to = [loki.write.in_cluster.receiver]

        stage.static_labels {
          values = {
            log_source = "kubernetes_pods",
          }
        }
      }

      // OTLP receiver configuration
      otelcol.receiver.otlp "otlp_receiver" {
        grpc {
          endpoint = "0.0.0.0:4317"
        }

        http {
          endpoint = "0.0.0.0:4318"

          cors {
            allowed_origins = ["*"]
            allowed_headers = ["*"]
            max_age         = 600
          }
        }

        output {
          traces = [otelcol.exporter.otlp.tempo.input]
        }
      }

      tracing {
        sampling_fraction = 0.1

        write_to = [otelcol.exporter.otlp.tempo.input]
      }

      // OTLP exporter to Tempo
      otelcol.exporter.otlp "tempo" {
        client {
          endpoint = sys.env("${tempoEndpoint}")
          tls {
            insecure = true
          }
        }
      }

      // writing
      loki.write "in_cluster" {
        endpoint {
          url = "${lokiEndpointUrl}/loki/api/v1/push"
        }
      }

  # Extra ports to expose OTLP receivers
  extraPorts:
    - name: otlp-grpc
      port: 4317
      targetPort: 4317
      protocol: TCP
    - name: otlp-http
      port: 4318
      targetPort: 4318
      protocol: TCP
