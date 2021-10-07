kind = "service-router"
name = "expense"

routes = [
  {
    match {
      http {
        header = [
          {
            name  = "X-Request-ID"
            regex  = "^[a-z].*"
          },
        ]
      }
    }

    destination {
      service        = "expense"
      service_subset = "java"
    }
  }
]