variable "resource_group_name" {
	type = string

}

variable "location" {
	type = string

}

variable "security_group" {
 type = list(object({
	name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = string
    }))
}

variable "web_nsg" {
    type = string

}

variable "source_address_prefix" {
    type = string
}


variable "target_subnet_id" {
	type = string
}

variable "tags" {
  type = map(string)
}