/**
 * # Azure Kubernetes Service (AKS) Module
 *
 * This module creates an AKS cluster with configurable settings
 */

# Resource Group data source to reference existing resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a managed identity for the AKS cluster
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.name}-identity"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  tags                = var.tags
}

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.name
  resource_group_name       = data.azurerm_resource_group.this.name
  location                  = var.location
  dns_prefix                = var.name
  kubernetes_version        = var.kubernetes_version
  private_cluster_enabled   = var.private_cluster_enabled
  sku_tier                  = var.sku_tier
  automatic_channel_upgrade = var.automatic_channel_upgrade
  tags                      = var.tags

  # Configure default node pool
  default_node_pool {
    name                 = var.default_node_pool.name
    vm_size              = var.default_node_pool.vm_size
    enable_auto_scaling  = var.default_node_pool.enable_auto_scaling
    min_count            = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count            = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    node_count           = var.default_node_pool.enable_auto_scaling ? null : var.default_node_pool.node_count
    vnet_subnet_id       = var.default_node_pool.vnet_subnet_id
    orchestrator_version = var.kubernetes_version
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    max_pods             = var.default_node_pool.max_pods
    node_labels          = var.default_node_pool.node_labels
    node_taints          = var.default_node_pool.node_taints
    zones                = var.default_node_pool.zones
  }

  # Configure identity for the cluster
  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks.id
  }

  # Configure Azure AD integration if specified
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.role_based_access_control != null ? [var.role_based_access_control] : []
    content {
      managed                = azure_active_directory_role_based_access_control.value.managed
      tenant_id              = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
    }
  }

  # Configure network profile
  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    service_cidr       = var.network_profile.service_cidr
    dns_service_ip     = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    outbound_type      = var.network_profile.outbound_type
  }

  # Configure OMS agent for monitoring
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # Configure auto-scaler profile
  auto_scaler_profile {
    balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
    expander                         = var.auto_scaler_profile.expander
    max_graceful_termination_sec     = var.auto_scaler_profile.max_graceful_termination_sec
    max_node_provisioning_time       = var.auto_scaler_profile.max_node_provisioning_time
    max_unready_nodes                = var.auto_scaler_profile.max_unready_nodes
    max_unready_percentage           = var.auto_scaler_profile.max_unready_percentage
    new_pod_scale_up_delay           = var.auto_scaler_profile.new_pod_scale_up_delay
    scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
    scan_interval                    = var.auto_scaler_profile.scan_interval
    scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
    scale_down_unready               = var.auto_scaler_profile.scale_down_unready
    scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
  }

  # Set lifecycle management for the cluster
  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version
    ]
  }
}

# Create additional node pools if specified
resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each              = { for np in var.additional_node_pools : np.name => np }
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count
  vnet_subnet_id        = each.value.vnet_subnet_id
  orchestrator_version  = var.kubernetes_version
  os_disk_size_gb       = each.value.os_disk_size_gb
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  zones                 = each.value.zones
  tags                  = var.tags

  lifecycle {
    ignore_changes = [
      orchestrator_version
    ]
  }
}
