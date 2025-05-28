# Azure Storage Account Module

This Terraform module creates an Azure Storage Account with configurable settings.

## Features

- Create an Azure Storage Account with various configuration options
- Configure storage account kind, tier, and replication options
- Enable or disable various security features like HTTPS traffic only
- Configure network rules for secure access
- Create and manage blob containers, file shares, and tables
- Enable diagnostic settings for monitoring

## Usage

```hcl
module "storage_account" {
  source              = "../../modules/storage-account"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
  name                = "mystorageaccount"
  account_tier        = "Standard"
  account_replication = "LRS"
  account_kind        = "StorageV2"
  
  containers = [
    {
      name        = "container1"
      access_type = "private"
    },
    {
      name        = "container2"
      access_type = "blob"
    }
  ]
  
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    bypass         = ["AzureServices"]
    subnet_ids     = []
  }

  tags = {
    Environment = "Production"
    Owner       = "Storage Team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure location where the storage account will be created | `string` | n/a | yes |
| name | Name of the storage account | `string` | n/a | yes |
| account_tier | Storage account tier (Standard or Premium) | `string` | `"Standard"` | no |
| account_replication | Storage account replication type (LRS, GRS, RAGRS, ZRS) | `string` | `"LRS"` | no |
| account_kind | Storage account kind (StorageV2, FileStorage, BlobStorage, etc.) | `string` | `"StorageV2"` | no |
| enable_https_traffic_only | Whether to enforce HTTPS traffic only | `bool` | `true` | no |
| min_tls_version | The minimum TLS version | `string` | `"TLS1_2"` | no |
| containers | List of container configurations | `list(object)` | `[]` | no |
| file_shares | List of file share configurations | `list(object)` | `[]` | no |
| tables | List of table configurations | `list(string)` | `[]` | no |
| network_rules | Network rules configuration | `object` | `null` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Account |
| name | The name of the Storage Account |
| primary_blob_endpoint | The primary blob endpoint URL |
| primary_access_key | The primary access key for the storage account |
| primary_connection_string | The primary connection string for the storage account |
| containers | Map of containers and their details |
| file_shares | Map of file shares and their details |
| tables | Map of table names and their resource IDs |
