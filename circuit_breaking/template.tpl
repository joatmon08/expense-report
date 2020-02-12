service {
  name    = "report"
  id      = "report-dotnet"
  address = "10.5.0.5"
  port    = 5002

  tags = ["circuit-break", "dotnet"]
  meta = {
    framework = "dotnet"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "10.5.0.5:20000"
        interval = "10s"
      }

      proxy {
        upstreams {
          destination_name   = "expense"
          local_bind_port    = 5001
          config {
            envoy_cluster_json = <<EOL
              {
                "@type": "type.googleapis.com/envoy.api.v2.Cluster",
                "name": "expense.default.dc1.internal.CONSUL_FQDN",
                "type": "EDS",
                "eds_cluster_config": {
                  "eds_config": {
                    "ads": {}
                  }
                },
                "connect_timeout": "5s",
                "outlier_detection": {
                  "consecutive_5xx": 10,
                  "consecutive_gateway_failure": 10,
                  "base_ejection_time": "30s"
                }
              }
            EOL

            envoy_listener_json = <<EOL
              {
              "@type": "type.googleapis.com/envoy.api.v2.Listener",
              "name": "expense:127.0.0.1:5001",
              "address": {
                "socketAddress": {
                  "address": "127.0.0.1",
                  "portValue": 5001
                }
              },
              "filterChains": [
                {
                  "filters": [
                    {
                      "name": "envoy.http_connection_manager",
                      "config": {
                        "stat_prefix": "expense",
                        "route_config": {
                          "name": "local_route",
                          "virtual_hosts": [
                            {
                              "name": "backend",
                              "domains": ["*"],
                              "routes": [
                                {
                                  "match": {
                                    "prefix": "/"
                                  },
                                  "route": {
                                    "cluster": "expense.default.dc1.internal.CONSUL_FQDN",
                                    "timeout": "60s",
                                    "retry_policy": {
                                      "retry_on": "5xx",
                                      "num_retries": 5,
                                      "per_try_timeout": "10s"
                                    }
                                  }
                                }
                              ]
                            }
                          ]
                        },
                        "http_filters": [
                          {
                            "name": "envoy.router",
                            "config": {}
                          }
                        ]
                      }
                    }
                  ]
                }
              ]
            }
            EOL
          }
        }
      }
    }
  }
}