# Azure Virtual Network Module

This Terraform module creates an Azure Virtual Network with configurable subnets.

## Features

- Create a Virtual Network with custom address space
- Create multiple subnets with optional service endpoints
- Configure network security groups (NSGs) for each subnet
- Support for service delegation in subnets
- Configure DNS servers for the virtual network

## Usage

```hcl
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = "my-resource-group"
  vnet_name           = "my-vnet"
  location            = "westeurope"
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name           = "subnet1"
      address_prefix = "10.0.1.0/24"
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
      delegation    = null
      nsg_rules     = []
    },
    {
      name           = "subnet2"
      address_prefix = "10.0.2.0/24"
      service_endpoints = []
      delegation    = null
      nsg_rules     = [
        {
          name                       = "allow_ssh"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  dns_servers = ["168.63.129.16"]

  tags = {
    Environment = "Production"
    Owner       = "Network Team"
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
| resource_group_name | Name of the resource group where the VNET will be created | `string` | n/a | yes |
| vnet_name | Name of the virtual network | `string` | n/a | yes |
| location | Azure location where the virtual network will be created | `string` | n/a | yes |
| address_space | The address space that is used the virtual network | `list(string)` | n/a | yes |
| subnets | List of subnet configurations | `list(object)` | `[]` | no |
| dns_servers | List of DNS servers IP addresses | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the Virtual Network |
| vnet_name | The name of the Virtual Network |
| vnet_address_space | The address space of the Virtual Network |
| subnet_ids | Map of subnet names and their IDs |
| subnet_address_prefixes | Map of subnet names and their address prefixes |
