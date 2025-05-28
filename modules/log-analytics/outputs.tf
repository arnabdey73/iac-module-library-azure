output "id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "resource_id" {
  description = "The Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_id" {
  description = "The Workspace ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "primary_shared_key" {
  description = "The Primary Shared Key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "secondary_shared_key" {
  description = "The Secondary Shared Key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "location" {
  description = "The Azure location of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.location
}

output "resource_group_name" {
  description = "The resource group name containing the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.resource_group_name
}

output "sku" {
  description = "The SKU of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.sku
}

output "retention_in_days" {
  description = "The data retention period in days"
  value       = azurerm_log_analytics_workspace.this.retention_in_days
}

output "daily_quota_gb" {
  description = "The daily data volume cap in GB"
  value       = azurerm_log_analytics_workspace.this.daily_quota_gb
}

output "solutions" {
  description = "Map of deployed Log Analytics solutions"
  value = {
    for k, v in azurerm_log_analytics_solution.this : k => {
      id            = v.id
      solution_name = v.solution_name
      publisher     = v.plan[0].publisher
      product       = v.plan[0].product
    }
  }
}
