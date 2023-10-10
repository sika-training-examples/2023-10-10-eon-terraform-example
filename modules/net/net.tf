terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}

variable "name" {
  type        = string
  description = "Name of the network"
}
variable "address_space" {
  type        = string
  description = "Address space of the network"
}
variable "subnets" {
  type        = list(string)
  description = "Subnets of the network"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}
variable "location" {
  type        = string
  description = "Location of the network"
}

resource "azurerm_virtual_network" "this" {
  name                = var.name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  count = length(var.subnets)

  name                 = "${var.name}${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnets[count.index]]
}

output "subnet_ids" {
  value = {
    for s in azurerm_subnet.this : s.address_prefixes[0] => s.id
  }
  description = "Map of subnet IDs"
}
