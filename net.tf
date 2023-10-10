module "net" {
  source = "./modules/net"

  name                = "eon"
  location            = local.location
  resource_group_name = azurerm_resource_group.eon.name
  address_space       = "10.250.0.0/16"
  subnets             = ["10.250.0.0/24"]
}
