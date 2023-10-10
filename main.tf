terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
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

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  location = "westeurope"
  suffix   = random_string.suffix.result
}

resource "azurerm_resource_group" "eon" {
  name     = "eon-ondrej"
  location = local.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "bar" {
  name                     = "bar${local.suffix}"
  resource_group_name      = azurerm_resource_group.eon.name
  location                 = azurerm_resource_group.eon.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

output "storage_account_names" {
  value = {
    bar = azurerm_storage_account.bar.name
  }
}

output "storage_account_access_keys" {
  value = {
    bar = azurerm_storage_account.bar.primary_access_key
  }
  sensitive = true
}
