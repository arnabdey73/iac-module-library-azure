variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure location where the storage account will be created"
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
  description = "Name of the storage account (must be globally unique, 3-24 chars, lowercase alphanumeric)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication)
    error_message = "Account replication must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
  
  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "enable_https_traffic_only" {
  description = "Whether to enforce HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "The minimum TLS version for secure connections"
  type        = string
  default     = "TLS1_2"
  
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "TLS version must be one of: TLS1_0, TLS1_1, TLS1_2."
  }
}

variable "containers" {
  description = "List of blob containers to create"
  type = list(object({
    name        = string
    access_type = string
  }))
  default = []
  
  validation {
    condition = alltrue([
      for container in var.containers :
      contains(["private", "blob", "container"], container.access_type)
    ])
    error_message = "Container access_type must be one of: private, blob, container."
  }
}

variable "file_shares" {
  description = "List of file shares to create"
  type = list(object({
    name  = string
    quota = number
  }))
  default = []
  
  validation {
    condition = alltrue([
      for share in var.file_shares :
      share.quota >= 1 && share.quota <= 102400
    ])
    error_message = "File share quota must be between 1 and 102400 GB."
  }
}

variable "tables" {
  description = "List of table names to create"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for table in var.tables :
      can(regex("^[A-Za-z][A-Za-z0-9]{2,62}$", table))
    ])
    error_message = "Table names must be 3-63 characters, start with a letter, and contain only alphanumeric characters."
  }
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
  
  validation {
    condition     = var.blob_soft_delete_retention_days >= 1 && var.blob_soft_delete_retention_days <= 365
    error_message = "Blob soft delete retention days must be between 1 and 365."
  }
}

variable "container_soft_delete_retention_days" {
  description = "Specifies the number of days that the container should be retained, between 1 and 365 days"
  type        = number
  default     = 7
  
  validation {
    condition     = var.container_soft_delete_retention_days >= 1 && var.container_soft_delete_retention_days <= 365
    error_message = "Container soft delete retention days must be between 1 and 365."
  }
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
