variable "prefix" {
  type        = string
  description = "The prefix for the resources created in the specified Azure Resource Group."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group in which the Virtual Network"
}

variable "location" {
  type        = string
  description = "The Azure Region in which to create the Virtual Network"
}

variable "retention_in_days" {
  type        = string
  description = "The retention period for the logs in days"
}

variable "log_analytics_workspace_sku" {
  type        = string
  description = "The SKU (pricing level) of the Log Analytics workspace"
}


variable "solutions" {
  type = object({
    publisher = string
    product   = string
  })
}

variable "tags" {
  default = {}
  type    = map(string)
}