variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location where the storage account will be created"
  type        = string
}

variable "name" {
  description = "Name of the storage account"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Storage account kind (StorageV2, FileStorage, BlobStorage, etc.)"
  type        = string
  default     = "StorageV2"
}

variable "enable_https_traffic_only" {
  description = "Whether to enforce HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "containers" {
  description = "List of container configurations"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
}

variable "file_shares" {
  description = "List of file share configurations"
  type = list(object({
    name  = string
    quota = number
  }))
  default = []
}

variable "tables" {
  description = "List of table configurations"
  type        = list(string)
  default     = []
}

variable "network_rules" {
  description = "Network rules configuration"
  type = object({
    default_action = string
    ip_rules       = list(string)
    subnet_ids     = list(string)
    bypass         = list(string)
  })
  default = null
}

variable "blob_soft_delete_retention_days" {
  description = "Specifies the number of days that the blob should be retained, between 1 and 365 days"
  type        = number
  default     = 7
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the container should be retained, between 1 and 365 days"
  type        = number
  default     = 7
}

variable "enable_versioning" {
  description = "Whether to enable versioning for this storage account"
  type        = bool
  default     = false
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for the storage account"
  type = object({
    log_analytics_workspace_id = string
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
