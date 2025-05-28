# Azure Log Analytics Workspace Module

This Terraform module creates a comprehensive Azure Log Analytics Workspace for centralized logging, monitoring, and observability. It provides flexible configuration options for data retention, monitoring solutions, and integration capabilities.

## Features

- **Log Analytics Workspace**: Centralized logging and monitoring workspace
- **Flexible Retention**: Configurable data retention periods (30-730 days)
- **SKU Options**: Support for Free, PerGB2018, PerNode, Premium, Standard, Standalone, Unlimited
- **Solution Integration**: Deploy monitoring solutions (Container Insights, Security Insights, etc.)
- **Diagnostic Settings**: Built-in diagnostic configuration for the workspace
- **Data Quota Management**: Optional daily data volume caps
- **Security**: Secure access with primary and secondary shared keys
- **Cost Optimization**: Daily quota limits to control costs

## Usage Examples

### Basic Log Analytics Workspace

```hcl
module "log_analytics" {
  source = "./modules/log-analytics"

  resource_group_name = "my-resource-group"
  location           = "East US"
  name               = "myapp-logs-workspace"
  
  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

### Advanced Configuration with Solutions

```hcl
module "log_analytics" {
  source = "./modules/log-analytics"

  resource_group_name = "enterprise-rg"
  location           = "East US"
  name               = "enterprise-logs-workspace"
  sku                = "PerGB2018"
  retention_in_days  = 90
  daily_quota_gb     = 10
  
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
    },
    {
      name      = "VMInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/VMInsights"
    }
  ]
  
  diagnostic_settings = {
    logs = {
      "Audit" = {
        enabled           = true
        retention_enabled = true
        retention_days    = 30
      }
    }
    metrics = {
      "AllMetrics" = {
        enabled           = true
        retention_enabled = true
        retention_days    = 30
      }
    }
  }
  
  tags = {
    Environment = "Production"
    CostCenter  = "IT-Operations"
    Owner       = "Platform Team"
  }
}
```

### Integration with AKS for Container Monitoring

```hcl
# Create Log Analytics workspace for AKS monitoring
module "aks_log_analytics" {
  source = "./modules/log-analytics"

  resource_group_name = "aks-cluster-rg"
  location           = "East US"
  name               = "aks-monitoring-workspace"
  sku                = "PerGB2018"
  retention_in_days  = 30
  
  solutions = [
    {
      name      = "ContainerInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
  ]
  
  tags = {
    Environment = "Production"
    Service     = "AKS-Monitoring"
  }
}

# Reference in AKS module
module "aks_cluster" {
  source = "./modules/aks-cluster"
  
  # ... other configuration ...
  log_analytics_workspace_id = module.aks_log_analytics.id
  oms_agent_enabled         = true
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
| [azurerm_log_analytics_solution.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the Log Analytics workspace will be created | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure location where the Log Analytics workspace will be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the Log Analytics workspace | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Pricing tier for the Log Analytics workspace | `string` | `"PerGB2018"` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Data retention period in days (30-730) | `number` | `30` | no |
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | Daily data volume cap in GB to control costs | `number` | `null` | no |
| <a name="input_solutions"></a> [solutions](#input\_solutions) | List of monitoring solutions to deploy | <pre>list(object({<br>    name      = string<br>    publisher = string<br>    product   = string<br>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for the workspace | <pre>object({<br>    logs = map(object({<br>      enabled          = bool<br>      retention_enabled = bool<br>      retention_days   = number<br>    }))<br>    metrics = map(object({<br>      enabled          = bool<br>      retention_enabled = bool<br>      retention_days   = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The resource ID of the Log Analytics Workspace |
| <a name="output_name"></a> [name](#output\_name) | The name of the Log Analytics Workspace |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The unique workspace ID for the Log Analytics Workspace |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | The primary shared key for the Log Analytics Workspace (sensitive) |
| <a name="output_secondary_shared_key"></a> [secondary\_shared\_key](#output\_secondary\_shared\_key) | The secondary shared key for the Log Analytics Workspace (sensitive) |
| <a name="output_location"></a> [location](#output\_location) | The Azure location of the Log Analytics Workspace |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name containing the Log Analytics Workspace |

## Common Solutions

| Solution Name | Publisher | Product | Description |
|--------------|-----------|---------|-------------|
| ContainerInsights | Microsoft | OMSGallery/ContainerInsights | Container and Kubernetes monitoring |
| SecurityInsights | Microsoft | OMSGallery/SecurityInsights | Azure Sentinel SIEM solution |
| VMInsights | Microsoft | OMSGallery/VMInsights | Virtual machine performance monitoring |
| ServiceMap | Microsoft | OMSGallery/ServiceMap | Application dependency mapping |
| AzureActivity | Microsoft | OMSGallery/AzureActivity | Azure activity log analysis |
| Updates | Microsoft | OMSGallery/Updates | Update management solution |

## Cost Management

- Use `daily_quota_gb` to set daily data ingestion limits
- Choose appropriate `sku` based on data volume:
  - **Free**: 500 MB/day, 7-day retention
  - **PerGB2018**: Pay-per-GB, flexible retention
  - **PerNode**: Fixed cost per monitored node
- Monitor data ingestion using Azure Cost Management
- Set up alerts for quota usage and costs

## Best Practices

1. **Naming Convention**: Use descriptive names that include environment and purpose
2. **Resource Grouping**: Place related monitoring resources in the same resource group
3. **Retention Policy**: Balance compliance requirements with storage costs
4. **Solutions**: Only deploy necessary solutions to avoid additional charges
5. **Security**: Store shared keys securely, consider using managed identities where possible
6. **Monitoring**: Set up alerts for workspace health and quota usage

## Examples

For complete working examples, see the [examples](../../examples/) directory:
- [Basic Log Analytics](../../examples/log-analytics-basic/)
- [AKS Integration](../../examples/aks-with-monitoring/)
- [Multi-solution Setup](../../examples/log-analytics-enterprise/)
