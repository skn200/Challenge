variable "resource_group_name" {
  description = " Resource Group of App Gateway"
  type        = string
}

variable "location" {
  description = "Azure region where App Gateway will be located"
  type        = string
}

variable "enable_http2" {
  description = "http enabled on App gateway"
  type        = bool
  default     = false
}

variable "name" {
  description = " Name of the App Gateway"
  type        = string
}

variable "sku" {
  description = "sku, tier and capacity of App Gaetway"
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "ssl_cert" {
  description = " ssl cert name, data, password and keyvault details of App Gateway"
  type = list(object({
    name                = string
    data                = string
    password            = string
    key_vault_secret_id = string
  }))
}

variable "identity" {
  description = "Manged Identity to be used in App Gateway"
  default     = null
  type = object({
    type = string
    ids  = list(string)
  })
}

variable "gateway_ip_conf" {
  description = " Gateway IP details of App Gateway"
  type = list(object({
    name      = string
    subnet_id = string
  }))
}

variable "frontend_port" {
  description = " Front End Port details of App Gateway"
  type = list(object({
    name = string
    port = number
  }))
}

variable "frontend_conf" {
  description = " Details of name, subnet id, private ip, public ip that will be used in App Gatewat "
  type = list(object({
    name         = string
    subnet_id    = string
    private_ip   = string
    public_ip_id = string
  }))
}

variable "backend_pool" {
  description = " Backend Pool name, fqdn and ips to be used in App Gateway"
  type = list(object({
    name  = string
    fqdns = list(string)
    ips   = list(string)
  }))
}

variable "probe" {
  description = " Health Probe details of App Gateway"
  type = list(object({
    name     = string
    protocol = string
    path     = string
    interval = number
    timeout  = number
    count    = number
    host     = string
  }))
}

variable "backend_setting" {
  description = " Backend Settings details of App Gateway"
  type = list(object({
    name        = string
    subnet_id   = string
    cookie_name = string
    port        = number
    protocol    = string
    host        = string
    timeout     = number
    probe_name  = string
    drain_time  = number
  }))
}

variable "listener" {
  description = " Listener details of App Gateway"
  type = list(object({
    name               = string
    frontend_conf_name = string
    frontend_port_name = string
    protocol           = string
    host               = string
    sni                = bool
    ssl_cert_name      = string
  }))
}

variable "rule" {
  description = " Routing Rule details of App Gateway"
  default     = []
  type = list(object({
    name                 = string
    type                 = string
    listener_name        = string
    backend_pool_name    = string
    backend_setting_name = string
  }))

}

variable "autoscale" {
  description = "Autoscale details of App Gateway"
  type = object({
    min = number
    max = number
  })
}


variable "tags" {
  default = {}
  type    = map(string)
}

variable "log_analytics_workspace_id" {
  type = string
}