variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location where the resources will be created"
  type        = string
}

variable "name" {
  description = "Name of the App Service"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU"
  type = object({
    tier     = string
    size     = string
    capacity = number
  })
  
  validation {
    condition     = contains(["Free", "Shared", "Basic", "Standard", "Premium", "PremiumV2", "PremiumV3", "Isolated", "IsolatedV2"], var.app_service_plan_sku.tier)
    error_message = "The SKU tier must be one of the supported values."
  }
}

variable "app_service_plan_kind" {
  description = "Kind of App Service Plan (Windows or Linux)"
  type        = string
  default     = "Windows"
  
  validation {
    condition     = contains(["Windows", "Linux"], var.app_service_plan_kind)
    error_message = "The App Service Plan kind must be either 'Windows' or 'Linux'."
  }
}

variable "https_only" {
  description = "Whether to enforce HTTPS traffic only"
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Map of application settings"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "List of connection strings"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for cs in var.connection_strings : contains(["SQLServer", "SQLAzure", "Custom", "PostgreSQL", "MySQL", "RedisCache"], cs.type)
    ])
    error_message = "Connection string type must be one of: SQLServer, SQLAzure, Custom, PostgreSQL, MySQL, RedisCache."
  }
}

variable "deployment_slots" {
  description = "List of deployment slot names"
  type        = list(string)
  default     = []
}

variable "site_config" {
  description = "Site configuration for the App Service"
  type = object({
    always_on                = optional(bool, true)
    dotnet_framework_version = optional(string, "v6.0")
    ftps_state               = optional(string, "Disabled")
    http2_enabled            = optional(bool, true)
    websockets_enabled       = optional(bool, false)
    minimum_tls_version      = optional(string, "1.2")
    linux_fx_version         = optional(string, null)
  })
  default = {}
}

variable "auth_settings" {
  description = "Authentication settings for the App Service"
  type = object({
    enabled                       = bool
    default_provider              = optional(string, "AzureActiveDirectory")
    unauthenticated_client_action = optional(string, "RedirectToLoginPage")
    token_store_enabled           = optional(bool, true)
    microsoft = optional(object({
      client_id     = string
      client_secret = string
    }), null)
  })
  default = null
}

variable "logs" {
  description = "Log configuration for the App Service"
  type = object({
    detailed_error_messages = optional(bool, false)
    failed_request_tracing  = optional(bool, false)
    application_logs = optional(object({
      file_system_level = optional(string, "Information")
      azure_blob_storage = optional(object({
        level             = string
        retention_in_days = number
        sas_url           = string
      }), null)
    }), null)
    http_logs = optional(object({
      file_system = optional(object({
        retention_in_days = number
        retention_in_mb   = number
      }), null)
      azure_blob_storage = optional(object({
        retention_in_days = number
        sas_url           = string
      }), null)
    }), null)
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
