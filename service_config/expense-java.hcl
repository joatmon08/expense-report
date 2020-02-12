service {
  name    = "expense"
  id      = "expense-java"
  address = "10.5.0.4"
  port    = 8080

  tags = ["java"]
  meta = {
    framework = "java"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "10.5.0.4:20000"
        interval = "10s"
      }

      proxy {
        upstreams {
          destination_name   = "expense-db-mysql"
          local_bind_address = "127.0.0.1"
          local_bind_port    = 3306
        }
      }
    }
  }
}