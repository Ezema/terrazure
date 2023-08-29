# Azure Infrastructure Automation with Terraform

## Overview

This repository contains Terraform code to provision and manage Azure infrastructure resources. The code defines various Azure resources such as a resource group, virtual network, subnet, network security groups, public IP, network interface, and a Linux virtual machine. These resources are orchestrated to create a basic network setup and deploy a Linux virtual machine with specified configurations.

## Terraform Features Utilized

- **Provider Configuration**: The Azure Provider (`azurerm`) is defined with a specific version (`3.0.0`) using the `required_providers` block.
- **Resource Provisioning**: The code defines multiple resource types such as `azurerm_resource_group`, `azurerm_virtual_network`, `azurerm_subnet`, `azurerm_network_security_group`, `azurerm_network_security_rule`, `azurerm_subnet_network_security_group_association`, `azurerm_public_ip`, `azurerm_network_interface`, and `azurerm_linux_virtual_machine`.
- **Interpolation**: Variables and attributes are interpolated using `${}` syntax to reference values between resources.
- **Data Source**: The `data` block is used to fetch information about an existing public IP address using the `azurerm_public_ip` data source.
- **Output Values**: The `output` block is used to display the public IP address of the deployed Linux virtual machine.

## Prerequisites

- Azure account with an active subscription
- Terraform installed locally
- SSH key pair for VM access

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/ezema/terrazure.git
   cd azure-terraform-project

2. Review and customize variables:
   Open variables.tf and update any variables as needed for your environment.

3. Deploy the infrastructure:
   terraform apply

4. Clean up:
   terraform destroy

## Configuration Details

- The `azurerm_resource_group` resource creates a resource group named `sampleResource` in the West Europe region with the tag `environment=dev`.
- The `azurerm_virtual_network` resource creates a virtual network named `sampleVirtualNetwork` with the specified address space.
- The `azurerm_subnet` resource creates a subnet within the virtual network.
- Network security groups are defined using `azurerm_network_security_group` and associated rules with `azurerm_network_security_rule`.
- The public IP address is created using `azurerm_public_ip`.
- The network interface for the VM is defined using `azurerm_network_interface`.
- The Linux virtual machine is defined using `azurerm_linux_virtual_machine`, including customization such as SSH key setup, OS disk configuration, and provisioning a Docker template.

## Outputs

- The public IP address of the deployed Linux virtual machine is displayed as output.
