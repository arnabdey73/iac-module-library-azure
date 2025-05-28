/**
 * # Azure App Service Module
 *
 * This module creates an App Service with configurable settings
 */

# Resource Group data source to reference existing resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create an App Service Plan
resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  os_type             = var.app_service_plan_kind == "Windows" ? "Windows" : "Linux"
  sku_name            = "${var.app_service_plan_sku.tier}${var.app_service_plan_sku.size}"
  worker_count        = var.app_service_plan_sku.capacity
  tags                = var.tags
}

# Create an App Service
resource "azurerm_windows_web_app" "this" {
  count               = var.app_service_plan_kind == "Windows" ? 1 : 0
  name                = var.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = var.https_only
  tags                = var.tags

  # Configure site settings
  site_config {
    always_on                 = var.site_config.always_on
    dotnet_framework_version  = var.site_config.dotnet_framework_version
    ftps_state                = var.site_config.ftps_state
    http2_enabled             = var.site_config.http2_enabled
    websockets_enabled        = var.site_config.websockets_enabled
    minimum_tls_version       = var.site_config.minimum_tls_version
  }

  # Configure application settings
  dynamic "app_settings" {
    for_each = var.app_settings
    content {
      name  = app_settings.key
      value = app_settings.value
    }
  }

  # Configure connection strings
  dynamic "connection_string" {
    for_each = { for cs in var.connection_strings : cs.name => cs }
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Configure identity
  identity {
    type = "SystemAssigned"
  }

  # Configure logs if specified
  dynamic "logs" {
    for_each = var.logs != null ? [var.logs] : []
    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      # Configure application logs
      dynamic "application_logs" {
        for_each = logs.value.application_logs != null ? [logs.value.application_logs] : []
        content {
          file_system_level = application_logs.value.file_system_level

          # Configure Azure blob storage for application logs
          dynamic "azure_blob_storage" {
            for_each = application_logs.value.azure_blob_storage != null ? [application_logs.value.azure_blob_storage] : []
            content {
              level             = azure_blob_storage.value.level
              retention_in_days = azure_blob_storage.value.retention_in_days
              sas_url           = azure_blob_storage.value.sas_url
            }
          }
        }
      }

      # Configure HTTP logs
      dynamic "http_logs" {
        for_each = logs.value.http_logs != null ? [logs.value.http_logs] : []
        content {
          # Configure file system HTTP logs
          dynamic "file_system" {
            for_each = http_logs.value.file_system != null ? [http_logs.value.file_system] : []
            content {
              retention_in_days = file_system.value.retention_in_days
              retention_in_mb   = file_system.value.retention_in_mb
            }
          }

          # Configure Azure blob storage for HTTP logs
          dynamic "azure_blob_storage" {
            for_each = http_logs.value.azure_blob_storage != null ? [http_logs.value.azure_blob_storage] : []
            content {
              retention_in_days = azure_blob_storage.value.retention_in_days
              sas_url           = azure_blob_storage.value.sas_url
            }
          }
        }
      }
    }
  }

  # Configure authentication settings if specified
  dynamic "auth_settings" {
    for_each = var.auth_settings != null ? [var.auth_settings] : []
    content {
      enabled                        = auth_settings.value.enabled
      default_provider               = auth_settings.value.default_provider
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action
      token_store_enabled            = auth_settings.value.token_store_enabled
      
      # Configure Microsoft provider
      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft != null ? [auth_settings.value.microsoft] : []
        content {
          client_id     = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because the Azure platform adds tags automatically
      tags["hidden-link"]
    ]
  }
}

# Create Linux App Service if kind is Linux
resource "azurerm_linux_web_app" "this" {
  count               = var.app_service_plan_kind == "Linux" ? 1 : 0
  name                = var.name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = var.https_only
  tags                = var.tags

  # Configure site settings
  site_config {
    always_on                 = var.site_config.always_on
    ftps_state                = var.site_config.ftps_state
    http2_enabled             = var.site_config.http2_enabled
    websockets_enabled        = var.site_config.websockets_enabled
    minimum_tls_version       = var.site_config.minimum_tls_version
    linux_fx_version          = var.site_config.linux_fx_version
  }

  # Configure application settings
  app_settings = var.app_settings

  # Configure connection strings
  dynamic "connection_string" {
    for_each = { for cs in var.connection_strings : cs.name => cs }
    content {
      name  = connection_string.key
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Configure identity
  identity {
    type = "SystemAssigned"
  }

  # Configure logs if specified
  dynamic "logs" {
    for_each = var.logs != null ? [var.logs] : []
    content {
      detailed_error_messages = logs.value.detailed_error_messages
      failed_request_tracing  = logs.value.failed_request_tracing

      # Configure application logs
      dynamic "application_logs" {
        for_each = logs.value.application_logs != null ? [logs.value.application_logs] : []
        content {
          file_system_level = application_logs.value.file_system_level

          # Configure Azure blob storage for application logs
          dynamic "azure_blob_storage" {
            for_each = application_logs.value.azure_blob_storage != null ? [application_logs.value.azure_blob_storage] : []
            content {
              level             = azure_blob_storage.value.level
              retention_in_days = azure_blob_storage.value.retention_in_days
              sas_url           = azure_blob_storage.value.sas_url
            }
          }
        }
      }

      # Configure HTTP logs
      dynamic "http_logs" {
        for_each = logs.value.http_logs != null ? [logs.value.http_logs] : []
        content {
          # Configure file system HTTP logs
          dynamic "file_system" {
            for_each = http_logs.value.file_system != null ? [http_logs.value.file_system] : []
            content {
              retention_in_days = file_system.value.retention_in_days
              retention_in_mb   = file_system.value.retention_in_mb
            }
          }

          # Configure Azure blob storage for HTTP logs
          dynamic "azure_blob_storage" {
            for_each = http_logs.value.azure_blob_storage != null ? [http_logs.value.azure_blob_storage] : []
            content {
              retention_in_days = azure_blob_storage.value.retention_in_days
              sas_url           = azure_blob_storage.value.sas_url
            }
          }
        }
      }
    }
  }

  # Configure authentication settings if specified
  dynamic "auth_settings" {
    for_each = var.auth_settings != null ? [var.auth_settings] : []
    content {
      enabled                        = auth_settings.value.enabled
      default_provider               = auth_settings.value.default_provider
      unauthenticated_client_action  = auth_settings.value.unauthenticated_client_action
      token_store_enabled            = auth_settings.value.token_store_enabled
      
      # Configure Microsoft provider
      dynamic "microsoft" {
        for_each = auth_settings.value.microsoft != null ? [auth_settings.value.microsoft] : []
        content {
          client_id     = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because the Azure platform adds tags automatically
      tags["hidden-link"]
    ]
  }
}

# Create deployment slots if specified
resource "azurerm_windows_web_app_slot" "this" {
  count          = var.app_service_plan_kind == "Windows" ? length(var.deployment_slots) : 0
  name           = var.deployment_slots[count.index]
  app_service_id = azurerm_windows_web_app.this[0].id
  tags           = var.tags

  # Configure site settings
  site_config {
    always_on                = var.site_config.always_on
    dotnet_framework_version = var.site_config.dotnet_framework_version
    ftps_state               = var.site_config.ftps_state
    http2_enabled            = var.site_config.http2_enabled
    websockets_enabled       = var.site_config.websockets_enabled
    minimum_tls_version      = var.site_config.minimum_tls_version
  }

  # Configure application settings - inherit from main app by default
  app_settings = var.app_settings

  # Configure identity
  identity {
    type = "SystemAssigned"
  }
}

# Create Linux deployment slots if specified
resource "azurerm_linux_web_app_slot" "this" {
  count          = var.app_service_plan_kind == "Linux" ? length(var.deployment_slots) : 0
  name           = var.deployment_slots[count.index]
  app_service_id = azurerm_linux_web_app.this[0].id
  tags           = var.tags

  # Configure site settings
  site_config {
    always_on            = var.site_config.always_on
    ftps_state           = var.site_config.ftps_state
    http2_enabled        = var.site_config.http2_enabled
    websockets_enabled   = var.site_config.websockets_enabled
    minimum_tls_version  = var.site_config.minimum_tls_version
    linux_fx_version     = var.site_config.linux_fx_version
  }

  # Configure application settings - inherit from main app by default
  app_settings = var.app_settings

  # Configure identity
  identity {
    type = "SystemAssigned"
  }
}
