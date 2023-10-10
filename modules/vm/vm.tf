terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}

variable "name" {
  description = "Name of the VM"
  type        = string
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}
variable "location" {
  type        = string
  description = "Location of the VM"
}
variable "subnet_id" {
  type        = string
  description = "ID of the subnet"
}
variable "size" {
  description = "Size of the VM"
  type        = string
  default     = "Standard_B1s"
}
variable "admin_username" {}
variable "admin_password" {}
variable "public_ip_enabled" {
  description = "Create a public IP"
  type        = bool
}
variable "user_data" {
  description = "User data"
  type        = string
  default     = ""
}

resource "azurerm_public_ip" "this" {
  count = var.public_ip_enabled ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_enabled ? azurerm_public_ip.this[0].id : null
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]
  user_data = base64encode(var.user_data)

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
}

output "public_ip" {
  value = var.public_ip_enabled ? azurerm_public_ip.this[0].ip_address : null
}

output "private_ip" {
  value = azurerm_network_interface.this.private_ip_address
}
