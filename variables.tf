variable "subscription_id" {
    type = string
}
variable "tenant_id" {}
variable "resource_group_name" {}
variable "environment" {}
variable "cluster_name" {}
variable "log_analytics_workspace_name" {}
variable "log_retention_in_days" {}
variable "backup_vault_name" {}
variable "node_count" {}
variable "vm_size" {}
variable "enable_network_policy" {}
variable "enable_azure_ad_integration" {}

variable "traefik_namespace" {
  description = "Namespace for Traefik"
  type        = string
}

variable "traefik_version" {
  description = "Version of Traefik chart"
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
}

variable "argocd_version" {
  description = "Version of ArgoCD chart"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for public FQDNs"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}