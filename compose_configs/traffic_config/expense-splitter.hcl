# Canary Release
kind = "service-splitter",
name = "expense"

splits = [
  {
    weight = 100,
    service_subset = "dotnet"
  },
  {
    weight = 0,
    service_subset = "java"
  }
]