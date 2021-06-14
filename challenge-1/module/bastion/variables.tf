variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}


variable "bastion_subnet_id" {
  description = "Subnet id of bastion host"
  type = string
}


variable "bastion_hostname" {
  description = "Bastion Hostname"
  type = string
 
}
