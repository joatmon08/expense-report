kind = "service-resolver"
name = "expense"

default_subset = "dotnet"

subsets = {
  dotnet = {
    filter = "Service.Meta.framework == dotnet"
  }
  java = {
    filter = "Service.Meta.framework == java"
  }
}
