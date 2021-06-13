variable "resource_group_name" {
  description = " Resource Group name of Vmss"
  type        = string
}

variable "location" {
  description = " Azure region where Vmss will be located"
  type        = string
}

variable "single_placement_group" {
  description = "if Single Placement Group will be enabled"
  type        = bool
}



variable "scale_set" {
  description = "Name, proximity placement group, health probe availability zone of Vmss "
  type = object({
    name     = string
    priority = string
    ppg_id   = string
    probe_id = string
    avzone   = list(string)
  })
}

variable "identity" {
  description = " Identity to be used by vmss"
  type = object({
    system      = bool
    user_id_ids = list(string)
  })
}

variable "sku" {
  description = " size, tier and vm count of Vmss"
  type = object({
    size     = string
    tier     = string
    capacity = number
  })
}

variable "policy" {
  description = " policy details of upgrade mode, automatic_os, eviction_policy and over provisioned for VMss "
  type = object({
    upgrade       = string
    os            = bool
    eviction      = string
    overprovision = bool
  })
}

variable "nic" {
  description = "Details of Subnet id, accelerated networking, IP forwarding, Network security Group, public ip, Appgw Backend pool id and Load Balancer backend pool id"
  type = object({
    subnet_id      = string
    accelerated    = bool
    ipforward      = bool
    nsg_id         = string
    pub_ip         = bool
    appgw_pool_ids = list(string)
    lb_pool_ids    = list(string)
  })
}

variable "root" {
  description = "User name and password to be used for Vmss"
  type = object({
    user_name  = string
    password   = string
  })
}

variable "os_image" {
  description = "Details of ID of custom image, publisher of image, offer(os flavour) of image, sku (os version) and version to be used for Vmss"
  type = object({
    id        = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "os_disk" {
  description = " Os Disk details (caching, sku and storage url) to be used for Vmss"
  type = object({
    caching     = string
    sku         = string
    storage_url = string
  })
}

variable "data_disk" {
  description = "Additional disk details (logical unit number, size, sku, storage url) to be used for Vmss"
  type = list(object({
    lun         = number
    size        = number
    caching     = string
    sku         = string
    storage_url = string
  }))
}



variable "tags" {
  default = {}
  type    = map(string)
}