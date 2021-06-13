locals {
  subnets = flatten([
    for sub in var.subnet : {
      name      = sub.name
      prefix    = sub.prefix
      endpoints = sub.endpoints
    }
  ])
  subnets_map = {
    for s in local.subnets : "${s.name}" => s
  }
}
resource "azurerm_resource_group" "network-rg" {
  name     = var.network-rg-name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet-name
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  address_space       = var.vnet-address-space
}

resource "azurerm_subnet" "subnet" {
  for_each = local.subnets_map

  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.network-rg.name

  address_prefixes  = each.value.prefix
  service_endpoints = each.value.endpoints != "" ? each.value.endpoints : null
}