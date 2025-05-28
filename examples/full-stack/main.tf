/**
 * # Full-Stack Azure Infrastructure Example
 *
 * This example demonstrates how to combine multiple modules to create a complete 
 * infrastructure stack in Azure, including networking, storage, monitoring, 
 * Kubernetes, and Web App components.
 */

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "full-stack-example-rg"
  location = "westeurope"
  tags = {
    Environment = "Demo"
    Department  = "DevOps"
  }
}

#-----------------------------------------
# Virtual Network Module
#-----------------------------------------
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.example.name
  vnet_name           = "full-stack-vnet"
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "app-service-subnet"
      address_prefix   = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
      delegation = {
        name         = "Microsoft.Web.serverFarms"
        service_name = "Microsoft.Web/serverFarms"
        actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
      nsg_rules = []
    },
    {
      name             = "aks-subnet"
      address_prefix   = "10.0.2.0/23"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      delegation = null
      nsg_rules = []
    },
    {
      name             = "storage-subnet"
      address_prefix   = "10.0.4.0/24"
      service_endpoints = ["Microsoft.Storage"]
      delegation = null
      nsg_rules = []
    }
  ]

  tags = {
    Environment = "Demo"
    Component   = "Network"
  }
}

#-----------------------------------------
# Log Analytics Module
#-----------------------------------------
module "log_analytics" {
  source              = "../../modules/log-analytics"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "full-stack-logs"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  
  solutions = [
    {
      name      = "ContainerInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    },
    {
      name      = "ApplicationInsights"
      publisher = "Microsoft"
      product   = "OMSGallery/ApplicationInsights"
    }
  ]
  
  tags = {
    Environment = "Demo"
    Component   = "Monitoring"
  }
}

#-----------------------------------------
# Storage Account Module
#-----------------------------------------
module "storage" {
  source              = "../../modules/storage-account"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "fullstackdemo${random_string.suffix.result}"
  account_tier        = "Standard"
  account_replication = "LRS"
  account_kind        = "StorageV2"
  
  containers = [
    {
      name        = "data"
      access_type = "private"
    },
    {
      name        = "logs"
      access_type = "private"
    }
  ]
  
  file_shares = [
    {
      name  = "config"
      quota = 5
    }
  ]
  
  tables = ["metrics", "events"]
  
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"] # In production, restrict this to specific IPs
    bypass         = ["AzureServices"]
    subnet_ids     = [module.vnet.subnet_ids["storage-subnet"]]
  }
  
  tags = {
    Environment = "Demo"
    Component   = "Storage"
  }
}

#-----------------------------------------
# AKS Cluster Module
#-----------------------------------------
module "aks" {
  source              = "../../modules/aks-cluster"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  name                = "full-stack-aks"
  kubernetes_version  = "1.28.0"
  
  default_node_pool = {
    name                = "default"
    vm_size             = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    node_count          = 1
    vnet_subnet_id      = module.vnet.subnet_ids["aks-subnet"]
  }
  
  network_profile = {
    network_plugin     = "azure"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
  
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = {
    Environment = "Demo"
    Component   = "Kubernetes"
  }
}

#-----------------------------------------
# App Service Module
#-----------------------------------------
module "app_service" {
  source                = "../../modules/app-service"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  name                  = "full-stack-webapp"
  app_service_plan_name = "full-stack-plan"
  
  app_service_plan_sku = {
    tier     = "Standard"
    size     = "S1"
    capacity = 1
  }
  
  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "dummy-key"  # In real environment, use App Insights key
    "WEBSITE_NODE_DEFAULT_VERSION"   = "~16"
    "STORAGE_CONNECTION_STRING"      = module.storage.primary_connection_string
  }
  
  connection_strings = [
    {
      name  = "Database"
      type  = "SQLAzure"
      value = "Server=tcp:example-server.database.windows.net;Database=exampledb;User ID=admin;Encrypt=true;"  # Use KeyVault in production
    }
  ]
  
  site_config = {
    always_on                 = true
    http2_enabled             = true
    websockets_enabled        = true
    dotnet_framework_version  = "v6.0"
  }
  
  deployment_slots = ["staging"]
  
  tags = {
    Environment = "Demo"
    Component   = "WebApp"
  }
}

# Random string to ensure storage account name uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

#-----------------------------------------
# Outputs
#-----------------------------------------
output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = module.vnet.vnet_id
}

output "log_analytics_workspace_id" {
  description = "The Workspace ID of the Log Analytics Workspace"
  value       = module.log_analytics.workspace_id
}

output "storage_account_name" {
  description = "The name of the Storage Account"
  value       = module.storage.name
}

output "aks_cluster_name" {
  description = "The name of the AKS Cluster"
  value       = module.aks.name
}

output "aks_node_resource_group" {
  description = "The auto-generated resource group for AKS cluster resources"
  value       = module.aks.node_resource_group
}

output "app_service_url" {
  description = "The default URL of the App Service"
  value       = "https://${module.app_service.default_hostname}"
}

output "app_service_slot_urls" {
  description = "The URLs of the deployment slots"
  value       = { for slot_name in ["staging"] : slot_name => "https://${module.app_service.name}-${slot_name}.azurewebsites.net" }
}
