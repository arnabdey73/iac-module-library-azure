/**
 * # Azure Log Analytics Workspace Module
 *
 * This module creates a Log Analytics Workspace with configurable settings
 */

# Resource Group data source to reference existing resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = var.tags

  lifecycle {
    precondition {
      condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
      error_message = "The retention period must be between 30 and 730 days."
    }
  }
}

# Create Log Analytics Solutions if specified
resource "azurerm_log_analytics_solution" "this" {
  for_each              = { for solution in var.solutions : solution.name => solution }
  solution_name         = each.key
  resource_group_name   = data.azurerm_resource_group.this.name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = each.value.publisher
    product   = each.value.product
  }

  tags = var.tags
}

# Configure diagnostic settings if specified
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings != null ? 1 : 0
  name                       = "${var.name}-diagnostic-settings"
  target_resource_id         = azurerm_log_analytics_workspace.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  dynamic "log" {
    for_each = var.diagnostic_settings.logs
    content {
      category = log.key
      enabled  = log.value.enabled

      retention_policy {
        enabled = log.value.retention_enabled
        days    = log.value.retention_days
      }
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_settings.metrics
    content {
      category = metric.key
      enabled  = metric.value.enabled

      retention_policy {
        enabled = metric.value.retention_enabled
        days    = metric.value.retention_days
      }
    }
  }
}
