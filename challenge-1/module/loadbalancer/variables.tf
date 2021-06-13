variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "sku" {
  type = string
}

variable "frontend_conf" {
  type = list(object({
    name         = string
    subnet_id    = string
    private_ip   = string
    public_ip_id = string
    avzone       = list(string)
  }))
}

variable "pool" {
  type = list(string)
}

variable "probe" {
  type = list(object({
    name         = string
    protocol     = string
    request_path = string
    port         = number
    interval     = number
    count        = number
  }))
}

variable "rule" {
  type = list(object({
    name               = string
    protocol           = string
    frontend_port      = string
    backend_port       = string
    frontend_conf_name = string
    probe_name         = string
    backend_pool_name  = string
    interval           = number
  }))
}

variable "outbound" {
  type = list(object({
    name                = string
    protocol            = string
    ports               = string
    idle_timeout        = number
    frontend_conf_names = list(string)
    backend_pool_name   = string
  }))
}


variable "tags" {
  default = {}
  type    = map(string)
}