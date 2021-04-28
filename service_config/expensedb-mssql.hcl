service {
  name    = "expense-db-mssql"
  id      = "expense-db-mssql"
  address = "10.5.0.6"
  port    = 1433
  checks = [
    {
      id       = "expense-db-mssql-tcp"
      name     = "TCP on port 1433"
      tcp      = "10.5.0.6:1433"
      interval = "30s"
      timeout  = "60s"
    }
  ]

  tags = ["mssql", "expense-report"]
  meta = {
    framework = "mssql"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        id       = "expense-db-mssql-sidecar-proxy-check"
        tcp      = "10.5.0.6:20000"
        interval = "10s"
      }

      proxy {
        config {
          protocol                   = "tcp"
          envoy_prometheus_bind_addr = "0.0.0.0:9102"
        }
      }
    }
  }
}