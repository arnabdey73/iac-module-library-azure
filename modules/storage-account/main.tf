/**
 * # Azure Storage Account Module
 *
 * This module creates a Storage Account with configurable settings
 */

# Resource Group data source to reference existing resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a Storage Account
resource "azurerm_storage_account" "this" {
  name                      = var.name
  resource_group_name       = data.azurerm_resource_group.this.name
  location                  = var.location
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication
  account_kind              = var.account_kind
  enable_https_traffic_only = var.enable_https_traffic_only
  min_tls_version           = var.min_tls_version
  tags                      = var.tags

  # If network rules are specified, configure them
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.subnet_ids
      bypass                     = network_rules.value.bypass
    }
  }

  # Optional blob properties configuration
  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.container_soft_delete_retention_days
    }

    versioning_enabled = var.enable_versioning
  }

  # Enable lifecycle management
  lifecycle {
    precondition {
      condition     = length(var.name) >= 3 && length(var.name) <= 24
      error_message = "The storage account name must be between 3 and 24 characters in length."
    }

    precondition {
      condition     = var.account_tier == "Standard" || var.account_tier == "Premium"
      error_message = "The storage account tier must be either 'Standard' or 'Premium'."
    }
  }
}

# Create Blob Containers if specified
resource "azurerm_storage_container" "container" {
  for_each              = { for container in var.containers : container.name => container }
  name                  = each.key
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = each.value.access_type
}

# Create File Shares if specified
resource "azurerm_storage_share" "share" {
  for_each             = { for share in var.file_shares : share.name => share }
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
  quota                = each.value.quota
}

# Create Tables if specified
resource "azurerm_storage_table" "table" {
  for_each             = toset(var.tables)
  name                 = each.key
  storage_account_name = azurerm_storage_account.this.name
}

# Configure diagnostic settings if specified
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings != null ? 1 : 0
  name                       = "${var.name}-diagnostic-settings"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = var.diagnostic_settings.log_analytics_workspace_id

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
