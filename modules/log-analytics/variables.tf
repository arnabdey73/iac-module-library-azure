variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location where the resources will be created"
  type        = string
}

variable "name" {
  description = "Name of the Log Analytics workspace"
  type        = string
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
