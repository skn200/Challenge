
resource "azurerm_public_ip" "bastion" {
  name                = "bastionpip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = var.bastion_hostname
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "ipconfiguration"
    subnet_id            = var.bastion_subnet_id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}
