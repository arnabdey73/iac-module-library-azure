variable "resource_group_name" {
  description = "Name of the resource group where the Log Analytics workspace will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure location where the Log Analytics workspace will be created"
  type        = string
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
      "westcentralus", "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope",
      "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "uksouth", "ukwest",
      "eastasia", "southeastasia", "japaneast", "japanwest", "koreacentral", "koreasouth",
      "southindia", "centralindia", "westindia", "australiaeast", "australiasoutheast",
      "australiacentral", "southafricanorth", "uaenorth"
    ], lower(var.location))
    error_message = "The location must be a valid Azure region."
  }
}

variable "name" {
  description = "Name of the Log Analytics workspace (must be globally unique)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.name))
    error_message = "Log Analytics workspace name must be 3-63 characters, start and end with alphanumeric, and contain only alphanumeric and hyphens."
  }
}

variable "sku" {
  description = "SKU of the Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "PerGB2018"], var.sku)
    error_message = "The SKU must be one of the following: Free, PerNode, Premium, Standard, Standalone, Unlimited, or PerGB2018."
  }
}

variable "retention_in_days" {
  description = "Retention period in days"
  type        = number
  default     = 30
  
  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "The retention period must be between 30 and 730 days."
  }
}

variable "daily_quota_gb" {
  description = "Daily data volume cap in GB"
  type        = number
  default     = null
}

variable "solutions" {
  description = "List of solutions to deploy"
  type = list(object({
    name      = string
    publisher = string
    product   = string
  }))
  default = []
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for the Log Analytics workspace"
  type = object({
    logs = map(object({
      enabled          = bool
      retention_enabled = bool
      retention_days   = number
    }))
    metrics = map(object({
      enabled          = bool
      retention_enabled = bool
      retention_days   = number
    }))
  })
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
