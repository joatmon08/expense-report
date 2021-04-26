service {
  name    = "expense"
  id      = "expense-dotnet"
  address = "10.5.0.7"
  port    = 5001
  checks = [
    {
      id       = "http"
      name     = "HTTP on port 5001"
      tcp      = "10.5.0.7:5001"
      interval = "30s"
      timeout  = "60s"
    }
  ]

  tags = ["dotnet", "expense-report"]
  meta = {
    framework = "dotnet"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "10.5.0.7:20000"
        interval = "10s"
      }

      proxy {
        upstreams {
          destination_name   = "expense-db-mssql"
          local_bind_address = "127.0.0.1"
          local_bind_port    = 1433
          config {
            protocol = "tcp"
          }
        }
        config {
          protocol                   = "http"
          envoy_prometheus_bind_addr = "0.0.0.0:9102"
        }
      }
    }
  }
}
