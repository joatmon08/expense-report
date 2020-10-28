service {
  name    = "report"
  id      = "report-dotnet"
  address = "10.5.0.5"
  port    = 5002

  tags = ["dotnet"]
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
          local_bind_address = "127.0.0.1"
          local_bind_port    = 5001

          config {
            connect_timeout_ms = 5000
            limits {
              max_connections         = 3
              max_pending_requests    = 4
              max_concurrent_requests = 5
            }
            passive_health_check {
              interval     = "30s"
              max_failures = 10
            }
          }
        }
      }
    }
  }
}
