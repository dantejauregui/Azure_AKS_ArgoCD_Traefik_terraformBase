terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.65.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25.0"
    }
  }
}

provider "azurerm" {
  features {}
  #Commenting below in case is run with Azure DevOps & its Service Principal (App registry + secret creted):
  #subscription_id = var.subscription_id
}

module "infra" {
  source = "./modules/infra"

  subscription_id             = var.subscription_id
  tenant_id                   = var.tenant_id
  resource_group_name         = var.resource_group_name
  location                    = var.location
  environment                 = var.environment
  cluster_name                = var.cluster_name
  dns_prefix                  = var.dns_prefix
  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_retention_in_days       = var.log_retention_in_days
  backup_vault_name           = var.backup_vault_name
  node_count                  = var.node_count
  vm_size                     = var.vm_size
  enable_network_policy       = var.enable_network_policy
  enable_azure_ad_integration = var.enable_azure_ad_integration
}

# Below will be provisioned manually as a 2nd step:
module "apps" {
  source = "./modules/apps"

  dns_prefix        = var.dns_prefix
  location          = var.location
  traefik_namespace = var.traefik_namespace
  traefik_version   = var.traefik_version
  argocd_namespace  = var.argocd_namespace
  argocd_version    = var.argocd_version
}
