data_dir  = "/tmp/"
log_level = "INFO"

datacenter = "dc1"

server = false

retry_join = ["10.5.0.2"]

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}