output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "storage_container_name" {
  value = module.storage.container_name
}

output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "aks_name" {
  value = module.aks.cluster_name
}

output "log_analytics_workspace_name" {
  value = module.aks.log_analytics_workspace_name
}

output "kube_config_command" {
  value = "az aks get-credentials -g ${azurerm_resource_group.this.name} -n ${module.aks.cluster_name} --overwrite-existing"
}

output "argocd_namespace" {
  value = helm_release.argocd.namespace
}

output "argocd_ui" {
  value = "kubectl -n argocd get svc argocd-server"
}

output "argocd_admin_password_command" {
  value = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
}
