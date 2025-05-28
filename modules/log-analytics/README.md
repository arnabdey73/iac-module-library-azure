# Azure Log Analytics Workspace Module

This Terraform module creates an Azure Log Analytics Workspace with configurable settings.

## Features

- Create an Azure Log Analytics Workspace with various configuration options
- Configure retention period, SKU, and daily quota
- Enable solutions for advanced analytics
- Configure diagnostic settings for the workspace itself
- Set up automated data collection rules

## Usage

```hcl
module "log_analytics" {
  source              = "../../modules/log-analytics"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
  name                = "my-log-analytics"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 5
  
  solutions = [
    {
      name      = "ContainerInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    },
    {
      name      = "SecurityInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/SecurityInsights"
    }
  ]

  tags = {
    Environment = "Production"
    Owner       = "DevOps Team"
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
| location | Azure location where the resources will be created | `string` | n/a | yes |
| name | Name of the Log Analytics workspace | `string` | n/a | yes |
| sku | SKU of the Log Analytics workspace | `string` | `"PerGB2018"` | no |
| retention_in_days | Retention period in days | `number` | `30` | no |
| daily_quota_gb | Daily data volume cap in GB | `number` | `null` | no |
| solutions | List of solutions to deploy | `list(object)` | `[]` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Log Analytics Workspace |
| name | The name of the Log Analytics Workspace |
| resource_id | The Resource ID of the Log Analytics Workspace |
| workspace_id | The Workspace ID of the Log Analytics Workspace |
| primary_shared_key | The Primary Shared Key of the Log Analytics Workspace |
| secondary_shared_key | The Secondary Shared Key of the Log Analytics Workspace |
