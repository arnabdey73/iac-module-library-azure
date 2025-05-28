output "id" {
  description = "The ID of the Storage Account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the Storage Account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "containers" {
  description = "Map of containers and their details"
  value       = { for container_key, container in azurerm_storage_container.container : container_key => {
    id   = container.id
    name = container.name
  } }
}

output "file_shares" {
  description = "Map of file shares and their details"
  value       = { for share_key, share in azurerm_storage_share.share : share_key => {
    id   = share.id
    name = share.name
  } }
}

output "tables" {
  description = "Map of table names and their resource IDs"
  value       = { for table_key, table in azurerm_storage_table.table : table_key => table.id }
}
