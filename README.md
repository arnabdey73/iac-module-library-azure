# Azure IaC Module Library

This repository contains a collection of reusable Terraform modules for provisioning common infrastructure components in Azure.

## Modules

The library includes the following modules:

- **vnet**: Azure Virtual Network configuration with subnets
- **storage-account**: Azure Storage Account with various configuration options
- **log-analytics**: Log Analytics workspace for centralized logging
- **aks-cluster**: Azure Kubernetes Service cluster with various configuration options
- **app-service**: Azure App Service for hosting web applications

## Usage

Each module can be used independently or in combination with others. See the `examples/` directory for sample implementations.

Basic usage example:

```hcl
module "vnet" {
  source              = "github.com/organization/iac-module-library-azure//modules/vnet"
  resource_group_name = "my-resource-group"
  vnet_name           = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  tags                = {
    Environment = "Production"
  }
}
```

## Getting Started

1. Clone this repository
2. Navigate to the example directory of choice
3. Initialize Terraform: `terraform init`
4. Apply the configuration: `terraform apply`

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
