variable "resource_group_name" {
  description = "Name of the resource group of db server"
  type        = string

}

variable "location" {
  description = "Azure region where sql server will be located"
  type        = string

  default = "eastus"
}

variable "sqlserver_name" {
  description = "sqlserver name"
  type        = string
}

variable "sqlserver" {
  description = "version and Login Id"
  type = object({
    db_version     = string
    admin_login_id = string
  })
}

variable "sqlpool" {
  description = " Name, Size, SKU (tier, family, scale up/out capacity), per_database_settings (min/max capacity) of elastic pool "
  type = object({
    name         = string
    size         = string
    sku_name     = string
    tier         = string
    family       = string
    capacity     = string
    min_capacity = string
    max_capacity = string
  })
}

variable "sqldb" {
  description = "Name and Size of Sql db"
  type = object({
    name = string
    size = string
  })
}


variable "sqlvnetrule_name" {
  description = " Name of vnet rule and subnet id which need to be added in the rule"
  type        = string
}

variable "sqlvnetrule_subnet_id" {
  description = " Name of vnet rule and subnet id which need to be added in the rule"
  type        = string
}


variable "tags" {
  type = map(string)
}


