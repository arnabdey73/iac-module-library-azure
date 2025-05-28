# Azure App Service Module

This Terraform module creates an Azure App Service with configurable settings.

## Features

- Create an Azure App Service with various configuration options
- Configure App Service Plan with auto-scaling
- Set up deployment slots for blue/green deployments
- Configure custom domains and SSL certificates
- Set up application settings and connection strings
- Enable advanced monitoring and diagnostic settings
- Configure network access and security settings

## Usage

```hcl
module "app_service" {
  source                 = "../../modules/app-service"
  resource_group_name    = "my-resource-group"
  location               = "westeurope"
  name                   = "my-webapp"
  app_service_plan_name  = "my-asp"
  app_service_plan_sku   = {
    tier     = "Standard"
    size     = "S1"
    capacity = 2
  }
  
  app_settings = {
    WEBSITE_NODE_DEFAULT_VERSION = "~14"
    APPINSIGHTS_INSTRUMENTATIONKEY = module.application_insights.instrumentation_key
  }
  
  connection_strings = [
    {
      name  = "Database"
      type  = "SQLAzure"
      value = "Server=tcp:server.database.windows.net;Database=db;User ID=user;Password=password;Encrypt=true;"
    }
  ]
  
  deployment_slots = ["staging", "testing"]
  
  site_config = {
    always_on                 = true
    dotnet_framework_version  = "v5.0"
    ftps_state                = "Disabled"
    http2_enabled             = true
    websockets_enabled        = false
    linux_fx_version          = null # For Windows apps
  }

  logs = {
    detailed_error_messages = true
    failed_request_tracing  = true
    application_logs = {
      file_system_level = "Information"
      azure_blob_storage = {
        level             = "Information"
        retention_in_days = 7
        sas_url           = "https://mystorageaccount.blob.core.windows.net/container?sv=2020-08-04&ss=bf&srt=c&sp=rwdlacitfx&se=2025-06-14T00:00:00Z&st=2022-06-14T00:00:00Z&spr=https&sig=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRST"
      }
    }
    http_logs = {
      file_system = {
        retention_in_days = 7
        retention_in_mb   = 35
      }
      azure_blob_storage = {
        retention_in_days = 7
        sas_url           = "https://mystorageaccount.blob.core.windows.net/container?sv=2020-08-04&ss=bf&srt=c&sp=rwdlacitfx&se=2025-06-14T00:00:00Z&st=2022-06-14T00:00:00Z&spr=https&sig=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRST"
      }
    }
  }

  tags = {
    Environment = "Production"
    Owner       = "Web Team"
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
| name | Name of the App Service | `string` | n/a | yes |
| app_service_plan_name | Name of the App Service Plan | `string` | n/a | yes |
| app_service_plan_sku | App Service Plan SKU | `object` | n/a | yes |
| app_service_plan_kind | Kind of App Service Plan (Windows or Linux) | `string` | `"Windows"` | no |
| app_settings | Map of application settings | `map(string)` | `{}` | no |
| connection_strings | List of connection strings | `list(object)` | `[]` | no |
| deployment_slots | List of deployment slot names | `list(string)` | `[]` | no |
| site_config | Site configuration for the App Service | `object` | `{}` | no |
| auth_settings | Authentication settings for the App Service | `object` | `null` | no |
| logs | Log configuration for the App Service | `object` | `null` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the App Service |
| name | The name of the App Service |
| default_hostname | The default hostname of the App Service |
| plan_id | The ID of the App Service Plan |
| deployment_slot_ids | Map of deployment slot names and their IDs |
| identity | The identity block of the App Service |
| outbound_ip_addresses | The outbound IP addresses of the App Service |
| possible_outbound_ip_addresses | The possible outbound IP addresses of the App Service |
