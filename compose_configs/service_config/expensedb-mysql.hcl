service {
  name    = "expense-db-mysql"
  id      = "expense-db-mysql"
  address = "10.5.0.3"
  port    = 3306
  checks = [
    {
      id       = "expense-db-mysql-tcp"
      name     = "TCP on port 3306"
      tcp      = "10.5.0.3:3306"
      interval = "30s"
      timeout  = "60s"
    }
  ]

  tags = ["mysql", "expense-report"]
  meta = {
    framework = "mysql"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Sidecar Listening"
        id       = "expense-db-mysql-sidecar-proxy-check"
        tcp      = "10.5.0.3:20000"
        interval = "10s"
      }

      proxy {
        config {
          protocol = "tcp"
        }
      }
    }
  }
}