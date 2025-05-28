/**
 * # Azure Virtual Network Module
 *
 * This module creates a Virtual Network with configurable subnets and NSGs
 */

# Resource Group data source to reference existing resource group
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  dns_servers         = var.dns_servers
  tags                = var.tags

  lifecycle {
    precondition {
      condition     = length(var.address_space) > 0
      error_message = "At least one address space must be provided."
    }
  }
}

# Create subnets if specified
resource "azurerm_subnet" "subnet" {
  for_each             = { for i, subnet in var.subnets : subnet.name => subnet }
  name                 = each.key
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.address_prefix]

  # Configure service endpoints if specified
  service_endpoints = each.value.service_endpoints

  # Configure delegation if specified
  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Create Network Security Groups for each subnet if rules are specified
resource "azurerm_network_security_group" "nsg" {
  for_each            = { for i, subnet in var.subnets : subnet.name => subnet if length(subnet.nsg_rules) > 0 }
  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags
}

# Create NSG rules
resource "azurerm_network_security_rule" "rule" {
  for_each                    = local.nsg_rules
  name                        = each.value.name
  resource_group_name         = data.azurerm_resource_group.this.name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.subnet_name].name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each                  = { for i, subnet in var.subnets : subnet.name => subnet if length(subnet.nsg_rules) > 0 }
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

locals {
  # Flatten subnet NSG rules for easier processing
  nsg_rules = flatten([
    for subnet_name, subnet in { for i, s in var.subnets : s.name => s if length(s.nsg_rules) > 0 } : [
      for rule_index, rule in subnet.nsg_rules : merge(rule, {
        subnet_name = subnet_name
        # Create a unique identifier for each NSG rule
        id = "${subnet_name}-${rule.name}"
      })
    ]
  ])
}
