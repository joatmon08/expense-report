service {
  name    = "expense"
  id      = "expense-java"
  address = "10.5.0.4"
  port    = 8080
  checks = [
    {
      id       = "expense-java-http"
      name     = "HTTP on port 8080"
      tcp      = "10.5.0.4:8080"
      interval = "30s"
      timeout  = "60s"
    }
  ]

  tags = ["java", "expense-report"]
  meta = {
    framework = "java"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        id       = "expense-java-sidecar-proxy-check"
        tcp      = "10.5.0.4:20000"
        interval = "10s"
      }

      proxy {
        upstreams {
          destination_name   = "expense-db-mysql"
          local_bind_address = "127.0.0.1"
          local_bind_port    = 3306
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