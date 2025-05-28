# Azure Storage Account Module

This Terraform module creates a comprehensive Azure Storage Account with advanced security, networking, and data management features. It supports multiple storage services including blobs, files, tables, and queues with configurable access policies and lifecycle management.

## Features

- **Storage Account**: Create Azure Storage Account with flexible configuration
- **Multiple Service Types**: Support for Blob, File, Table, and Queue storage
- **Security**: HTTPS-only traffic, configurable TLS versions, network ACLs
- **Data Protection**: Soft delete, versioning, lifecycle management
- **Access Control**: Container-level access policies, shared access signatures
- **Network Security**: Virtual network integration, private endpoints, firewall rules
- **Monitoring**: Diagnostic settings and metrics integration
- **Cost Optimization**: Automatic tier management and lifecycle policies
- **Compliance**: Encryption at rest and in transit, audit logging

## Usage Examples

### Basic Storage Account

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  resource_group_name = "my-resource-group"
  location           = "East US"
  name               = "mystorageaccount001"
  
  containers = [
    {
      name        = "documents"
      access_type = "private"
    }
  ]
  
  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

### Advanced Storage Account with Security

```hcl
module "storage_account" {
  source = "./modules/storage-account"

  resource_group_name = "enterprise-rg"
  location           = "East US"
  name               = "enterprisestorage001"
  account_tier       = "Standard"
  account_replication = "GRS"
  account_kind       = "StorageV2"
  
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  enable_versioning        = true
  
  blob_soft_delete_retention_days      = 30
  container_soft_delete_retention_days = 30
  
  containers = [
    {
      name        = "application-data"
      access_type = "private"
    },
    {
      name        = "public-assets"
      access_type = "blob"
    },
    {
      name        = "backups"
      access_type = "private"
    }
  ]
  
  file_shares = [
    {
      name  = "shared-documents"
      quota = 100
    },
    {
      name  = "application-configs"
      quota = 50
    }
  ]
  
  tables = [
    "ApplicationLogs",
    "UserSessions",
    "ConfigurationData"
  ]
  
  network_rules = {
    default_action = "Deny"
    ip_rules       = [
      "203.0.113.0/24",
      "198.51.100.0/24"
    ]
    bypass     = ["AzureServices", "Logging", "Metrics"]
    subnet_ids = []
  }
  
  diagnostic_settings = {
    log_analytics_workspace_id = "/subscriptions/sub-id/resourceGroups/monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/logs-workspace"
    metrics = {
      "Transaction" = {
        enabled           = true
        retention_enabled = true
        retention_days    = 90
      }
      "Capacity" = {
        enabled           = true
        retention_enabled = true
        retention_days    = 90
      }
    }
  }
  
  tags = {
    Environment = "Production"
    CostCenter  = "IT-Infrastructure"
    Owner       = "Platform Team"
    Backup      = "Required"
  }
}
```

### Storage for Static Website Hosting

```hcl
module "website_storage" {
  source = "./modules/storage-account"

  resource_group_name = "website-rg"
  location           = "East US"
  name               = "websitestorage001"
  account_tier       = "Standard"
  account_replication = "LRS"
  
  containers = [
    {
      name        = "$web"
      access_type = "blob"
    },
    {
      name        = "assets"
      access_type = "blob"
    }
  ]
  
  # Enable static website hosting in additional configuration
  static_website = {
    enabled               = true
    index_document        = "index.html"
    error_404_document    = "404.html"
  }
  
  tags = {
    Environment = "Production"
    Service     = "Website"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_share.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the storage account will be created | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location where the storage account will be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the storage account (must be globally unique, 3-24 chars, lowercase alphanumeric) | `string` | n/a | yes |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Storage account tier (Standard or Premium) | `string` | `"Standard"` | no |
| <a name="input_account_replication"></a> [account\_replication](#input\_account\_replication) | Storage account replication type | `string` | `"LRS"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Storage account kind | `string` | `"StorageV2"` | no |
| <a name="input_enable_https_traffic_only"></a> [enable\_https\_traffic\_only](#input\_enable\_https\_traffic\_only) | Whether to enforce HTTPS traffic only | `bool` | `true` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum TLS version for secure connections | `string` | `"TLS1_2"` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Whether to enable blob versioning | `bool` | `false` | no |
| <a name="input_blob_soft_delete_retention_days"></a> [blob\_soft\_delete\_retention\_days](#input\_blob\_soft\_delete\_retention\_days) | Number of days to retain deleted blobs (1-365) | `number` | `7` | no |
| <a name="input_container_soft_delete_retention_days"></a> [container\_soft\_delete\_retention\_days](#input\_container\_soft\_delete\_retention\_days) | Number of days to retain deleted containers (1-365) | `number` | `7` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of blob containers to create | <pre>list(object({<br>    name        = string<br>    access_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | List of file shares to create | <pre>list(object({<br>    name  = string<br>    quota = number<br>  }))</pre> | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of table names to create | `list(string)` | `[]` | no |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network access rules configuration | <pre>object({<br>    default_action = string<br>    ip_rules       = list(string)<br>    subnet_ids     = list(string)<br>    bypass         = list(string)<br>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration | <pre>object({<br>    log_analytics_workspace_id = string<br>    metrics = map(object({<br>      enabled          = bool<br>      retention_enabled = bool<br>      retention_days   = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Storage Account |
| <a name="output_name"></a> [name](#output\_name) | The name of the Storage Account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob service endpoint URL |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | The primary file service endpoint URL |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | The primary table service endpoint URL |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | The primary queue service endpoint URL |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account (sensitive) |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the storage account (sensitive) |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the storage account (sensitive) |
| <a name="output_containers"></a> [containers](#output\_containers) | Map of created containers and their properties |
| <a name="output_file_shares"></a> [file\_shares](#output\_file\_shares) | Map of created file shares and their properties |
| <a name="output_tables"></a> [tables](#output\_tables) | Map of created tables and their resource IDs |

## Container Access Types

| Access Type | Description | Use Case |
|-------------|-------------|----------|
| `private` | No anonymous access | Secure internal data, application files |
| `blob` | Anonymous read access for blobs only | Public assets, downloads, CDN content |
| `container` | Anonymous read access for containers and blobs | Public file listings, open datasets |

## Replication Types

| Type | Description | Durability | Use Case |
|------|-------------|------------|----------|
| `LRS` | Locally Redundant Storage | 99.999999999% (11 9's) | Cost-effective, same datacenter |
| `ZRS` | Zone Redundant Storage | 99.9999999999% (12 9's) | High availability, same region |
| `GRS` | Geo Redundant Storage | 99.99999999999999% (16 9's) | Disaster recovery, cross-region |
| `GZRS` | Geo Zone Redundant Storage | 99.99999999999999% (16 9's) | Maximum durability and availability |

## Performance Tiers

| Tier | IOPS | Throughput | Use Case |
|------|------|------------|----------|
| `Standard` | Up to 20,000 | Up to 500 MB/s | General purpose, cost-effective |
| `Premium` | Up to 100,000 | Up to 2,000 MB/s | High-performance applications, databases |

## Security Best Practices

1. **Network Security**: Use network rules to restrict access by IP ranges and VNets
2. **HTTPS Only**: Always enable HTTPS-only traffic for data in transit
3. **TLS Version**: Use TLS 1.2 or higher for secure connections
4. **Access Keys**: Rotate storage access keys regularly
5. **Shared Access Signatures**: Use SAS tokens for time-limited access
6. **Soft Delete**: Enable soft delete for data recovery capabilities
7. **Versioning**: Enable versioning for critical data protection
8. **Monitoring**: Configure diagnostic settings for security monitoring

## Cost Optimization

- Choose appropriate replication type based on availability requirements
- Use lifecycle management policies to automatically tier data
- Enable soft delete with appropriate retention periods
- Monitor storage metrics to optimize usage patterns
- Use reserved capacity for predictable workloads

## Examples

For complete working examples, see the [examples](../../examples/) directory:
- [Basic Storage](../../examples/storage-basic/)
- [Website Hosting](../../examples/storage-website/)
- [Enterprise Storage](../../examples/storage-enterprise/)
