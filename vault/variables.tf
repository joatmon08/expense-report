variable "cluster_name" {
  type        = string
  description = "cluster name"
}

variable "cluster_zone" {
  type        = string
  description = "cluster zone from GKE"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "namespace for services"
  default     = "default"
}

variable "application" {
  type        = string
  description = "application prefix for secrets"
}

variable "application_v2" {
  type        = string
  description = "application (v2) name for secrets"
}

variable "mysql_username" {
  type        = string
  description = "admin username for mysql database"
  default     = "root"
  sensitive   = true
}

variable "mysql_password" {
  type        = string
  description = "admin password for mysql database"
  sensitive   = true
}

variable "mysql_service" {
  type        = string
  description = "endpoint for mysql database"
}

variable "mysql_port" {
  type        = string
  description = "port for mysql database"
  default     = "3306"
}

variable "mssql_username" {
  type        = string
  description = "admin username for mssql database"
  default     = "SA"
  sensitive   = true
}

variable "mssql_password" {
  type        = string
  description = "admin password for mssql database"
}

variable "mssql_service" {
  type        = string
  description = "endpoint for mssql database"
}

variable "mssql_port" {
  type        = string
  description = "port for mysql database"
  default     = "1433"
}
