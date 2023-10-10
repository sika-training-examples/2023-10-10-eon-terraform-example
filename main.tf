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
    prevent_destroy = false
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

resource "azurerm_storage_container" "bar" {
  # for_each = { for i in range(0, 5) : tostring(i) => null }
  for_each = toset([
    "1",
    "2",
    "4",
  ])

  name                  = "bar${each.key}"
  storage_account_name  = azurerm_storage_account.bar.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "bar2" {
  for_each = {
    aaa = true
    bbb = false
  }

  name                  = "bar2-${each.key}"
  storage_account_name  = azurerm_storage_account.bar.name
  container_access_type = each.value ? "blob" : "private"
}

resource "azurerm_storage_container" "bar3" {
  for_each = {
    aaa = {
      access_type = "blob"
      metadata = {
        name = "aaa"
      }
    }
    bbb = {
      access_type = "container"
      metadata = {
        name = "bbb"
      }
    }
  }

  name                  = "bar3-${each.key}"
  storage_account_name  = azurerm_storage_account.bar.name
  container_access_type = each.value.access_type
  metadata              = each.value.metadata
}

locals {
  enabled = true
}

resource "azurerm_resource_group" "hello" {
  count = local.enabled ? 1 : 0

  name     = "eon-hello"
  location = local.location
}

locals {
  resorce_group_hello_name = length(azurerm_resource_group.hello) == 1 ? azurerm_resource_group.hello[0].name : null
}

output "name" {
  value = local.resorce_group_hello_name
}

resource "azurerm_resource_group" "eon-delete" {
  name     = "eon-ondrej-delete"
  location = local.location

  lifecycle {
    prevent_destroy = false
  }
}
