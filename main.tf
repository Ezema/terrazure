terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sampleResourceGroup" {
  name     = "sampleResource"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "sampleVirtualNetwork" {
  name                = "sampleVirtualNetwork"
  resource_group_name = azurerm_resource_group.sampleResourceGroup.name
  location            = azurerm_resource_group.sampleResourceGroup.location
  address_space       = ["10.123.0.0/16"]
  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "sampleSubnet" {
  name                 = "sampleSubnet"
  resource_group_name  = azurerm_resource_group.sampleResourceGroup.name
  virtual_network_name = azurerm_virtual_network.sampleVirtualNetwork.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "sampleNetworkSecurityGroup" {
  name                = "sampleNetworkSecurityGroup"
  location            = azurerm_resource_group.sampleResourceGroup.location
  resource_group_name = azurerm_resource_group.sampleResourceGroup.name
  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "sampleNetworkSecurityRule" {
  name                        = "sampleNetworkSecurityRule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.sampleResourceGroup.name
  network_security_group_name = azurerm_network_security_group.sampleNetworkSecurityGroup.name
}

resource "azurerm_subnet_network_security_group_association" "sampleSubnetNetworkSecGroupAssociation" {
  subnet_id                 = azurerm_subnet.sampleSubnet.id
  network_security_group_id = azurerm_network_security_group.sampleNetworkSecurityGroup.id
}

resource "azurerm_public_ip" "samplePublicIP" {
  name                = "samplePublicIP_default"
  resource_group_name = azurerm_resource_group.sampleResourceGroup.name
  location            = azurerm_resource_group.sampleResourceGroup.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "sampleNIC" {
  name                = "sampleNIC"
  location            = azurerm_resource_group.sampleResourceGroup.location
  resource_group_name = azurerm_resource_group.sampleResourceGroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sampleSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.samplePublicIP.id
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "sampleVirtualMachine" {
  name                = "sampleVirtualMachine"
  resource_group_name = azurerm_resource_group.sampleResourceGroup.name
  location            = azurerm_resource_group.sampleResourceGroup.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.sampleNIC.id,
  ]

  custom_data = filebase64("docker_template.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/temp/azure_ezema.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", {
        hostname = self.public_ip_address
        user = "adminuser"
        identityfile = "~/.ssh/temp/azure_ezema"
    })
    interpreter = var.host_os=="linux"? ["bash","-c"] : ["Powershell", "-Command"]
  }
}

data "azurerm_public_ip" "dataSampleIP" {
     name = azurerm_public_ip.samplePublicIP.name
     resource_group_name = azurerm_resource_group.sampleResourceGroup.name
}

output "public_instance_ip_addr" {
    value="${azurerm_linux_virtual_machine.sampleVirtualMachine.name}: ${data.azurerm_public_ip.dataSampleIP.ip_address}"
}