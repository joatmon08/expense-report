kind = "proxy-defaults"
name = "global"

config {
  protocol                   = "http"
  envoy_prometheus_bind_addr = "0.0.0.0:9102"

  envoy_extra_static_clusters_json = <<EOL
    {
      "connect_timeout": "3.000s",
      "dns_lookup_family": "V4_ONLY",
      "lb_policy": "ROUND_ROBIN",
      "load_assignment": {
          "cluster_name": "jaeger_9411",
          "endpoints": [
              {
                  "lb_endpoints": [
                      {
                          "endpoint": {
                              "address": {
                                  "socket_address": {
                                      "address": "10.5.0.10",
                                      "port_value": 9411,
                                      "protocol": "TCP"
                                  }
                              }
                          }
                      }
                  ]
              }
          ]
      },
      "name": "jaeger_9411",
      "type": "STRICT_DNS"
    }
  EOL

  envoy_tracing_json = <<EOL
    {
        "http": {
            "config": {
                "@type": type.googleapis.com/envoy.config.trace.v3.ZipkinConfig
                "collector_cluster": "jaeger_9411",
                "collector_endpoint": "/api/v2/spans"
            },
            "name": "envoy.zipkin"
        }
    }
  EOL
}
