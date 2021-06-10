resource "azurerm_network_security_group" "web-nsg" {
  name                = var.web_nsg
  resource_group_name = var.resource_group
  location            = var.location
  
  security_rule {
    name                       = "allow-jumpbox"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = var.jumpbox_subnet_cidr
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
  
  security_rule {
    name                       = "allow-webserver"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = var.web_subnet_cidr
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
}
}

resource "azurerm_subnet_network_security_group_association" "web-nsg-subnet" {
  subnet_id                 = var.web_subnet_id
  network_security_group_id = azurerm_network_security_group.web-nsg.id
}


resource "azurerm_network_security_group" "app-nsg" {
    name                = var.app_nsg
    resource_group_name = var.resource_group
    location            = var.location

    security_rule {
      name                       = "allow-jumpbox"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = var.jumpbox_subnet_cidr
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
  }
    security_rule {
      name                       = "allow-web-subnet"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = var.web_subnet_cidr
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = ["22", "80"]
  }

}

resource "azurerm_subnet_network_security_group_association" "app-nsg-subnet" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.app-nsg.id
}


resource "azurerm_network_security_group" "db-nsg" {
    name                = var.db_nsg
    resource_group_name = var.resource_group
    location            = var.location

    security_rule {
        name                       = "allow-app-subnet"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_address_prefix      = var.app_subnet_cidr
        source_port_range          = "*"
        destination_address_prefix = "*"
        destination_port_range     = "3306"
    }
    
}

resource "azurerm_subnet_network_security_group_association" "db-nsg-subnet" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}