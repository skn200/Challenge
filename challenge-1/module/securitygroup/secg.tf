locals {
  security_group = flatten([
    for value in var.security_group: {
     name                       = value.name
     priority                   = value.priority
     direction                  = value.direction
     access                     = value.access
     protocol                   = value.protocol
     source_port_range          = value.source_port_range
     destination_address_prefix = value.destination_address_prefix
     destination_port_range     = value.destination_port_range
    }
  ])
  security_group_map = {
    for value in local.security_group: "${value.name}" => value
  }
}


data "azurerm_subnet" "example" {
  name                 = "sot-subnet"
  virtual_network_name = "cloudengg-poc"
  resource_group_name  = "cloudengg-ansible"
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.web_nsg
  resource_group_name = var.resource_group
  location            = var.location
  
  dynamic "security_rule" {
   for_each = local.security_group_map
   iterator = object
   content {
     name                       = object.value.name
     priority                   = object.value.priority
     direction                  = object.value.direction
     access                     = object.value.access
     protocol                   = object.value.protocol
     source_address_prefix      = var.source_address_prefix
     source_port_range          = object.value.source_port_range
     destination_address_prefix = object.value.destination_address_prefix
     destination_port_range     = object.value.destination_port_range
  }
  }

  tags = var.tags
  
}

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
  subnet_id                 = var.target_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


