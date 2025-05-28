output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names and their IDs"
  value       = { for subnet_key, subnet in azurerm_subnet.subnet : subnet_key => subnet.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names and their address prefixes"
  value       = { for subnet_key, subnet in azurerm_subnet.subnet : subnet_key => subnet.address_prefixes[0] }
}
