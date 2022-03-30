service {
  name    = "expense"
  id      = "expense-dotnet"
  address = "10.5.0.7"
  port    = 80
  checks = [
    {
      id       = "expense-dotnet-http"
      name     = "HTTP on port 80"
      tcp      = "10.5.0.7:80"
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
        id       = "expense-dotnet-sidecar-proxy-check"
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
      }
    }
  }
}
