terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}

variable "azurerm_client_id" {}
variable "azurerm_client_secret" {}
variable "azurerm_tenant_id" {}
variable "azurerm_subscription_id" {}

provider "azurerm" {
  features {}

  client_id       = var.azurerm_client_id
  client_secret   = var.azurerm_client_secret
  tenant_id       = var.azurerm_tenant_id
  subscription_id = var.azurerm_subscription_id
}

resource "azurerm_resource_group" "eon" {
  name     = "eon-ondrej"
  location = "westeurope"

  lifecycle {
    prevent_destroy = true
  }
}
