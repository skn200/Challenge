variable "resource_group_name" {
  description = "Name of the resource group of db server"
  type        = string
}

variable "location" {
  description = "Azure region where keyvault will be located"
  type        = string
}


variable "keyvault_name" {
  type = string
}

variable "keyvault" {
  type = object({
    soft_delete_enabled   = bool
    soft_delete_retention = string
    purge_enabled         = bool
    sku                   = string
  })
}


variable "certificate_permission" {
  description = "List of permision required for Certificate"
  type        = list(string)
}

variable "secret_permission" {
  description = "List of permission required for secrets"
  type        = list(string)
}

variable "certificate_name" {
  description = "Name of the Certificate to be created"
  type        = string
}

variable "appgw_name" {
  description = "User Assigned Identity name to be used "
  type        = string
}

variable "dns_names" {
  description = "DNS name of the certificate"
  type        = list(string)
}

variable "common-name" {
  description = "Common Name of the certificate"
  type        = string
}

variable "vmss_user"{
  type =string
}

variable "tags" {
  type = map(string)
}