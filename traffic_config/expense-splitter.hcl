# Canary Release
kind = "service-splitter",
name = "expense"

splits = [
  {
    weight = 90,
    service_subset = "dotnet"
  },
  {
    weight = 10,
    service_subset = "java"
  }
]