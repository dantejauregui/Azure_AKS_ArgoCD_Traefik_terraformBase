variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "aks-prod-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-prod-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "aks-prod"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "traefik_version" {
  description = "Version of Traefik to install"
  type        = string
  default     = "10.24.0"
}

variable "traefik_namespace" {
  description = "Namespace for Traefik installation"
  type        = string
  default     = "traefik"
}

variable "argocd_version" {
  description = "Version of Argo CD to install"
  type        = string
  default     = "5.46.8"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD installation"
  type        = string
  default     = "argocd"
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
  default     = "production"
}

# Monitoring and Logging
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "aks-logs"
}

variable "log_retention_in_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

# Backup
variable "backup_vault_name" {
  description = "Name of the Backup Vault"
  type        = string
  default     = "aks-backup-vault"
}

# Security
variable "enable_azure_ad_integration" {
  description = "Enable Azure AD integration for AKS"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy for AKS"
  type        = bool
  default     = true
} 

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}