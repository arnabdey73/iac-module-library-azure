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

output "secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = azurerm_storage_account.this.secondary_access_key
  sensitive   = true
}

output "secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.this.secondary_connection_string
  sensitive   = true
}

output "primary_file_endpoint" {
  description = "The primary file service endpoint URL"
  value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_table_endpoint" {
  description = "The primary table service endpoint URL"
  value       = azurerm_storage_account.this.primary_table_endpoint
}

output "primary_queue_endpoint" {
  description = "The primary queue service endpoint URL"
  value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "location" {
  description = "The Azure location of the Storage Account"
  value       = azurerm_storage_account.this.location
}

output "resource_group_name" {
  description = "The resource group name containing the Storage Account"
  value       = azurerm_storage_account.this.resource_group_name
}

output "account_tier" {
  description = "The tier of the Storage Account"
  value       = azurerm_storage_account.this.account_tier
}

output "account_replication_type" {
  description = "The replication type of the Storage Account"
  value       = azurerm_storage_account.this.account_replication_type
}

output "account_kind" {
  description = "The kind of the Storage Account"
  value       = azurerm_storage_account.this.account_kind
}

output "containers" {
  description = "Map of created containers and their properties"
  value       = { for container_key, container in azurerm_storage_container.container : container_key => {
    id          = container.id
    name        = container.name
    url         = "${azurerm_storage_account.this.primary_blob_endpoint}${container.name}"
    access_type = container.container_access_type
  } }
}

output "file_shares" {
  description = "Map of created file shares and their properties"
  value       = { for share_key, share in azurerm_storage_share.share : share_key => {
    id    = share.id
    name  = share.name
    url   = "${azurerm_storage_account.this.primary_file_endpoint}${share.name}"
    quota = share.quota
  } }
}

output "tables" {
  description = "Map of created tables and their resource IDs"
  value       = { for table_key, table in azurerm_storage_table.table : table_key => {
    id   = table.id
    name = table.name
    url  = "${azurerm_storage_account.this.primary_table_endpoint}${table.name}"
  } }
}
