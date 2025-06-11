output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}

output "traefik_namespace" {
  value = kubernetes_namespace.traefik.metadata[0].name
}

output "traefik_version" {
  value = helm_release.traefik.version
}

output "argocd_namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_version" {
  value = helm_release.argocd.version
}

output "argocd_url" {
  value = "https://argocd.${var.dns_prefix}.${var.location}.cloudapp.azure.com"
}

output "argocd_admin_password" {
  value     = "admin"
  sensitive = true
}

# Monitoring outputs
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.workspace_id
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.main.name
}

# Backup outputs
output "backup_vault_name" {
  value = azurerm_recovery_services_vault.main.name
}

output "backup_policy_name" {
  value = azurerm_backup_policy_vm.aks.name
} 