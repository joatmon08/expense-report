service {
  name    = "expense-db-mysql"
  id      = "expense-db-mysql"
  address = "10.5.0.3"
  port    = 3306

  tags = ["mysql"]
  meta = {
    framework = "mysql"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "10.5.0.3:20000"
        interval = "10s"
      }

      proxy {}
    }
  }
}