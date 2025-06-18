subscription_id = "<YOUR-SUBSCRIPTION-ID>"
tenant_id = "<YOUR-TENANT-ID>"
resource_group_name = "aks-prod-rg"
location = "eastus"
environment = "production"
cluster_name = "aks-prod"
dns_prefix = "aks-prod"

log_analytics_workspace_name = "aks-logs"
log_retention_in_days = 30
backup_vault_name = "aks-backup"

node_count = 3
vm_size = "Standard_DS2_v2"
enable_network_policy = true
enable_azure_ad_integration = true

traefik_namespace = "traefik"
traefik_version = "10.24.0"

argocd_namespace = "argocd"
argocd_version = "5.46.7"
