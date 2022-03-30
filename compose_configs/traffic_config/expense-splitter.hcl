# Canary Release
kind = "service-splitter",
name = "expense"

splits = [
  {
    weight = 50,
    service_subset = "dotnet"
  },
  {
    weight = 50,
    service_subset = "java"
  }
]