# A/B test
kind = "service-router"

name = "expense"

routes = [
  {
    match {
      http {
        header = [
          {
            name  = "testgroup"
            exact = "b"
          },
        ]
      }
    }

    destination {
      service        = "expense"
      service_subset = "java"
    }
  },
  {
    match {
      http {
        path_prefix = "/"
      }
    }

    destination {
      service = "expense"
    }
  },
]