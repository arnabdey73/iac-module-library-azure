output "id" {
  description = "The ID of the App Service"
  value       = var.app_service_plan_kind == "Windows" ? azurerm_windows_web_app.this[0].id : azurerm_linux_web_app.this[0].id
}

output "name" {
  description = "The name of the App Service"
  value       = var.name
}

output "default_hostname" {
  description = "The default hostname of the App Service"
  value       = var.app_service_plan_kind == "Windows" ? azurerm_windows_web_app.this[0].default_hostname : azurerm_linux_web_app.this[0].default_hostname
}

output "plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}

output "deployment_slot_ids" {
  description = "Map of deployment slot names and their IDs"
  value       = var.app_service_plan_kind == "Windows" ? {
    for i, slot in azurerm_windows_web_app_slot.this : var.deployment_slots[i] => slot.id
  } : {
    for i, slot in azurerm_linux_web_app_slot.this : var.deployment_slots[i] => slot.id
  }
}

output "identity" {
  description = "The identity block of the App Service"
  value       = var.app_service_plan_kind == "Windows" ? azurerm_windows_web_app.this[0].identity : azurerm_linux_web_app.this[0].identity
}

output "outbound_ip_addresses" {
  description = "The outbound IP addresses of the App Service"
  value       = var.app_service_plan_kind == "Windows" ? azurerm_windows_web_app.this[0].outbound_ip_addresses : azurerm_linux_web_app.this[0].outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the App Service"
  value       = var.app_service_plan_kind == "Windows" ? azurerm_windows_web_app.this[0].possible_outbound_ip_addresses : azurerm_linux_web_app.this[0].possible_outbound_ip_addresses
}
