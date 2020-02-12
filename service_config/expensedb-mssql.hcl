service {
  name    = "expense-db-mssql"
  id      = "expense-db-mssql"
  address = "10.5.0.6"
  port    = 1433

  tags = ["mssql"]
  meta = {
    framework = "mssql"
  }

  connect {
    sidecar_service {
      port = 20000

      check {
        name     = "Connect Envoy Sidecar"
        tcp      = "10.5.0.6:20000"
        interval = "10s"
      }

      proxy {}
    }
  }
}