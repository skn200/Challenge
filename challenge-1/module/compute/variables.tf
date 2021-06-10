variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "avset" {
  type = object({
    name    = string
    ud      = string
    fd      = string
    managed = bool
  })
}


variable "instance" {
  type = list(object({
    name  = string
    size  = string
  }))
}

variable "nic" {
  type = object({
    subnet_id = string
  })
}

variable "root" {
  type = object({
    user_name  = string
    ssh_key    = string
  })
}

variable "os_image" {
  type = object({
    id          = string
    publisher   = string
    offer       = string
    sku         = string
    version     = string
  })
}

variable "os_disk" {
  type = object({
    name      = string
    size      = number
    caching   = string
    sku       = string
  })
}

variable "data_disk" {
  type = list(object({
    name      = string
    lun       = number
    size      = number
    caching   = string
    sku       = string
  }))
}


variable "custom_data" {
  type = string
}


variable "tags" {
  default = { }
  type = map(string)
}