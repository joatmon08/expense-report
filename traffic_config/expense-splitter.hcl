# Canary Release
kind = "service-splitter",
name = "expense"

splits = [
  {
    weight = 20,
    service_subset = "dotnet"
  },
  {
    weight = 80,
    service_subset = "java"
  }
]