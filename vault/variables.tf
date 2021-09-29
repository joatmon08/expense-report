variable "cluster_name" {
  type        = string
  description = "cluster name from GKE"
}

variable "cluster_zone" {
  type        = string
  description = "cluster zone from GKE"
}

variable "namespace" {
  type        = string
  description = "namespace for services"
  default     = "default"
}

variable "application" {
  type        = string
  description = "application name for secrets"
}

variable "db_username" {
  type        = string
  description = "bootstrap username for database"
  default     = "root"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "bootstrap password for database"
  sensitive   = true
}

variable "db_service" {
  type        = string
  description = "endpoint for database"
}

variable "db_port" {
  type        = string
  description = "port for database"
  default     = "3306"
}

locals {
  db_role = "${var.application}-db"
}

data "google_client_config" "default" {}

data "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.cluster_zone
}

data "kubernetes_service_account" "vault" {
  metadata {
    name = "vault"
  }
}

data "kubernetes_secret" "vault" {
  metadata {
    name = data.kubernetes_service_account.vault.default_secret_name
  }
}