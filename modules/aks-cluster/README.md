# Azure Kubernetes Service (AKS) Module

This Terraform module creates an Azure Kubernetes Service (AKS) cluster with configurable settings.

## Features

- Create an AKS cluster with customizable configurations
- Configure node pools with different VM sizes and auto-scaling
- Enable managed identity for improved security
- Configure network settings including CNI or kubenet networking
- Enable monitoring integration with Azure Monitor
- Set up role-based access control (RBAC) with Azure AD integration
- Configure advanced networking options

## Usage

```hcl
module "aks_cluster" {
  source              = "../../modules/aks-cluster"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
  name                = "my-aks-cluster"
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
  
  additional_node_pools = [
    {
      name                = "workload"
      vm_size             = "Standard_D4s_v3"
      enable_auto_scaling = true
      min_count           = 0
      max_count           = 5
      node_count          = 1
      node_labels         = { "workloadType" = "cpu" }
      node_taints         = ["dedicated=cpu:NoSchedule"]
      vnet_subnet_id      = module.vnet.subnet_ids["aks-workload-subnet"]
    }
  ]

  network_profile = {
    network_plugin     = "azure"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
  
  log_analytics_workspace_id = module.log_analytics.id
  
  tags = {
    Environment = "Production"
    Owner       = "K8S Team"
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
| name | Name of the AKS cluster | `string` | n/a | yes |
| kubernetes_version | Kubernetes version | `string` | n/a | yes |
| default_node_pool | Default node pool configuration | `object` | n/a | yes |
| additional_node_pools | List of additional node pool configurations | `list(object)` | `[]` | no |
| network_profile | Network profile configuration | `object` | n/a | yes |
| log_analytics_workspace_id | Log Analytics workspace ID for container insights | `string` | `null` | no |
| role_based_access_control | Role-based access control configuration | `object` | n/a | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the AKS Cluster |
| name | The name of the AKS Cluster |
| kube_config_raw | The raw kube config file |
| kube_admin_config_raw | The raw kube admin config file |
| node_resource_group | The auto-generated resource group for cluster resources |
| kubelet_identity | The kubelet identity used by the AKS cluster |
| host | The Kubernetes cluster server host |
| client_key | The client key for authentication |
| client_certificate | The client certificate for authentication |
