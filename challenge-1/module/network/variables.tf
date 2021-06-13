variable "network-rg-name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet-name" {
  type = string
}

variable "vnet-address-space" {
  type = list(string)
}

variable "subnet" {
  type = list(object({
    name      = string
    prefix    = list(string)
    endpoints = list(string)
  }))
}