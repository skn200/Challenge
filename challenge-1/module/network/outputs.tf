output "virtual_network" {
  value = {
    id      = azurerm_virtual_network.vnet.id
    name    = azurerm_virtual_network.vnet.name
    adresss = azurerm_virtual_network.vnet.address_space
  }

}
output "subnet" {
  value = {
    for key, value in azurerm_subnet.subnet : value.name => {
      name    = value.name
      id      = value.id
      adresss = value.address_prefix
    }
  }
}