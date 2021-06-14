resource "azurerm_network_security_group" "bastion-nsg" {
  name                         = "bastion-nsg"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  security_rule {
    name                       = "Allow-internet-gateway"
    description                = "Allow TCP 443 from Internet and Gateway Manager"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-TCP-to-web-subnet"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = ["22"]
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = var.web_subnet_cidr
  }
  
  security_rule {
    name                       = "Allow-TCP-to-app-subnet"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = ["22"]
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = var.app_subnet_cidr
  }


}

resource "azurerm_subnet_network_security_group_association" "bastion-nsg" {
  subnet_id                 = var.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.bastion-nsg.id
}


resource "azurerm_network_security_group" "web-nsg" {
  name                     = "web-nsg"
  resource_group_name      = var.resource_group_name
  location                 = var.location

  security_rule {
    name                              = "Allow-from-bastion"
    priority                          = 1000
    direction                         = "Inbound"
    access                            = "Allow"
    protocol                          = "Tcp"
    source_port_range                 = "*"
    destination_port_range            = ["22"]
    source_address_prefix             = var.bastion_subnet_cidr
    destination_address_prefix        = "*"
  }

  security_rule {
    name                               = "Allow_Gateway_Traffic_"
    description                        = "Allow traffic from Application Gateway"
    priority                           = 1001
    direction                          = "Inbound"
    access                             = "Allow"
    protocol                           = "*"
    source_port_range                  = "80"
    destination_port_range             = "*"
    source_address_prefix              = var.appgw_subnet_cidr
    destination_address_prefix         = "*"
  }


}

resource "azurerm_subnet_network_security_group_association" "web-nsg" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}


resource "azurerm_network_security_group" "app-nsg" {
  name                     = "app-nsg"
  resource_group_name      = var.resource_group_name
  location                 = var.location

  security_rule {
    name                              = "Allow-from-bastion"
    priority                          = 1000
    direction                         = "Inbound"
    access                            = "Allow"
    protocol                          = "Tcp"
    source_port_range                 = "*"
    destination_port_range            = ["22"]
    source_address_prefix             = var.bastion_subnet_cidr
    destination_address_prefix        = "*"
  }

  security_rule {
    name                              = "Allow_WebTier_traffic"
    priority                          = 1001
    direction                         = "Inbound"
    access                            = "Allow"
    protocol                          = "*"
    source_port_range                 = "80"
    destination_port_range            = "*"
    source_address_prefix             = var.web_subnet_cidr
    destination_address_prefix        = "*"
  }


}

resource "azurerm_subnet_network_security_group_association" "app-nsg" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}