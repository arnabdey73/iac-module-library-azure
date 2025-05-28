/**
 * # Virtual Network Example
 *
 * This example demonstrates how to use the VNET module to create a virtual network with multiple subnets.
 */

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "vnet-example-rg"
  location = "westeurope"
  tags = {
    Environment = "Example"
  }
}

# Create a virtual network using the vnet module
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.example.name
  vnet_name           = "example-vnet"
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "web-subnet"
      address_prefix   = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = null
      nsg_rules = [
        {
          name                       = "allow_http"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "allow_https"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "app-subnet"
      address_prefix   = "10.0.2.0/24"
      service_endpoints = ["Microsoft.Storage"]
      delegation = null
      nsg_rules = [
        {
          name                       = "allow_https"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.0.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "db-subnet"
      address_prefix   = "10.0.3.0/24"
      service_endpoints = ["Microsoft.Sql"]
      delegation = null
      nsg_rules = [
        {
          name                       = "allow_sql"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.2.0/24"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name             = "aks-subnet"
      address_prefix   = "10.0.4.0/22"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
      delegation = null
      nsg_rules = [
        {
          name                       = "allow_internal_traffic"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "VirtualNetwork"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  dns_servers = ["168.63.129.16"]

  tags = {
    Environment = "Example"
    Department  = "IT"
    Purpose     = "Infrastructure Demo"
  }
}

# Output the VNET details
output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}
