data_dir  = "/tmp/"
log_level = "DEBUG"

datacenter = "dc1"

server = true

bootstrap_expect = 1
ui               = true

bind_addr   = "0.0.0.0"
client_addr = "0.0.0.0"

ports {
  grpc = 8502
}

connect {
  enabled = true
}

advertise_addr                = "10.5.0.2"
enable_central_service_config = true

ui_config {
  enabled = true

  metrics_provider = "prometheus"
  metrics_proxy = {
    base_url = "http://10.5.0.12:9090"
  }
}

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"

      config {
        protocol                   = "http"
        envoy_prometheus_bind_addr = "0.0.0.0:9102"

        envoy_tracing_json = <<EOF
{
  "http": {
    "name": "envoy.tracers.zipkin",
    "typedConfig": {
      "@type": "type.googleapis.com/envoy.config.trace.v3.ZipkinConfig",
      "collector_cluster": "jaeger",
      "collector_endpoint_version": "HTTP_JSON",
      "collector_endpoint": "/api/v2/spans",
      "shared_span_context": true
    }
  }
}
EOF

        envoy_extra_static_clusters_json = <<EOF2
{
  "name": "jaeger",
  "type": "STRICT_DNS",
  "connect_timeout": "5s",
  "load_assignment": {
    "cluster_name": "jaeger",
    "endpoints": [
      {
        "lb_endpoints": [
          {
            "endpoint": {
              "address": {
                "socket_address": {
                  "address": "10.5.0.10",
                  "port_value": 9411
                }
              }
            }
          }
        ]
      }
    ]
  }
}
EOF2
      }
    }
  ]
}