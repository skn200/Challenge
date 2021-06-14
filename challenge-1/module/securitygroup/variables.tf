
variable "resource_group_name" {
  type = string

}

variable "location" {
  type = string

}

variable "bastion_subnet_cidr" {
  type = string
}

variable "bastion_subnet_id" {
  type = string
}

variable "web_subnet_cidr" {
  type = string
}

variable "web_subnet_id" {
  type = string
}

variable "app_subnet_cidr" {
  type = string
}

variable "app_subnet_id" {
  type = string
}

variable "appgw_subnet_cidr" {
  type = string
}