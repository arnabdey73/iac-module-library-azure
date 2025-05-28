variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location where the resources will be created"
  type        = string
}

variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Whether to enable private cluster"
  type        = bool
  default     = false
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster"
  type        = string
  default     = "Free"
  
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "The SKU tier must be one of the following: Free, Standard, Premium."
  }
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for the Kubernetes cluster"
  type        = string
  default     = "stable"
  
  validation {
    condition     = contains(["none", "patch", "stable", "rapid", "node-image"], var.automatic_channel_upgrade)
    error_message = "The upgrade channel must be one of the following: none, patch, stable, rapid, node-image."
  }
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_count          = number
    vnet_subnet_id      = string
    os_disk_size_gb     = optional(number, 128)
    max_pods            = optional(number, 30)
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    zones               = optional(list(string), [])
  })
}

variable "additional_node_pools" {
  description = "List of additional node pool configurations"
  type = list(object({
    name                = string
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    node_count          = number
    vnet_subnet_id      = string
    os_disk_size_gb     = optional(number, 128)
    max_pods            = optional(number, 30)
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    zones               = optional(list(string), [])
  }))
  default = []
}

variable "network_profile" {
  description = "Network profile configuration"
  type = object({
    network_plugin     = string
    network_policy     = optional(string, "calico")
    service_cidr       = string
    dns_service_ip     = string
    docker_bridge_cidr = string
    outbound_type      = optional(string, "loadBalancer")
  })
  
  validation {
    condition     = contains(["azure", "kubenet"], var.network_profile.network_plugin)
    error_message = "The network plugin must be one of the following: azure, kubenet."
  }
}

variable "role_based_access_control" {
  description = "Role-based access control configuration"
  type = object({
    managed                = bool
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string), [])
    azure_rbac_enabled     = optional(bool, false)
  })
  default = null
}

variable "auto_scaler_profile" {
  description = "Auto-scaler profile configuration"
  type = object({
    balance_similar_node_groups      = optional(bool, false)
    expander                         = optional(string, "random")
    max_graceful_termination_sec     = optional(number, 600)
    max_node_provisioning_time       = optional(string, "15m")
    max_unready_nodes                = optional(number, 3)
    max_unready_percentage           = optional(number, 45)
    new_pod_scale_up_delay           = optional(string, "10s")
    scale_down_delay_after_add       = optional(string, "10m")
    scale_down_delay_after_delete    = optional(string, "10s")
    scale_down_delay_after_failure   = optional(string, "3m")
    scan_interval                    = optional(string, "10s")
    scale_down_unneeded              = optional(string, "10m")
    scale_down_unready               = optional(string, "20m")
    scale_down_utilization_threshold = optional(number, 0.5)
  })
  default = {}
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for container insights"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
