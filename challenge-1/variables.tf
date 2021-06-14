variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

############## NETWORK ##############
variable "network-rg-name" {
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

######################### SECURITY GROUPS ##############


variable "bastion_subnet_cidr" {
  type = string
}

variable "web_subnet_cidr" {
  type = string
}

variable "app_subnet_cidr" {
  type = string
}

variable "appgw_subnet_cidr" {
  type = string
}


######################### BASTION #####################

variable "bastion_hostname" {
  description = "Bastion Hostname"
  type = string
 
}


######################### Log Analytics ################

variable "prefix" {
  type = string
}

variable "retention_in_days" {
  type = string
}

variable "log_analytics_workspace_sku" {
  type = string
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

################################# Key Vault ##################


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

variable "vmss_user" {
  type = string
}

variable "certificate_permission" {
  type = list(string)
}

variable "secret_permission" {
  type = list(string)
}

variable "certificate_name" {
  type = string
}

variable "dns_names" {
  type = list(string)
}

variable "common_name" {
  type = string
}


#################### APP GATEWAY #################


variable "enable_http2" {
  type = bool
}

variable "appgw_name" {
  type = string
}

variable "appgw_sku" {
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "appgw_frontend_port" {
  description = " Front End Port details of App Gateway"
  type = list(object({
    name = string
    port = number
  }))
}

variable "appgw_backend_pool" {
  description = " Backend Pool name, fqdn and ips to be used in App Gateway"
  type = list(object({
    name  = string
    fqdns = list(string)
    ips   = list(string)
  }))
}

variable "appgw_probe" {
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

variable "appgw_listener" {
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

variable "appgw_rule" {
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

variable "appgw_autoscale" {
  description = "Autoscale details of App Gateway"
  type = object({
    min = number
    max = number
  })
}


############################## WEB TIER ###############################

variable "web_single_placement_group" {
  description = "if Single Placement Group will be enabled"
  type        = bool
}

variable "web_scale_set" {
  description = "Name, proximity placement group, health probe availability zone of Vmss "
  type = object({
    name     = string
    priority = string
    ppg_id   = string
    probe_id = string
    avzone   = list(string)
  })
}

variable "web_sku" {
  description = " size, tier and vm count of Vmss"
  type = object({
    size     = string
    tier     = string
    capacity = number
  })
}

variable "web_policy" {
  description = " policy details of upgrade mode, automatic_os, eviction_policy and over provisioned for VMss "
  type = object({
    upgrade       = string
    os            = bool
    eviction      = string
    overprovision = bool
  })
}

variable "web_vmss" {
  description = "User name and ssh key to be used for Vmss"
  type = object({
    user_name = string
  })
}

variable "web_os_image" {
  description = "Details of ID of custom image, publisher of image, offer(os flavour) of image, sku (os version) and version to be used for Vmss"
  type = object({
    id        = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "web_os_disk" {
  description = " Os Disk details (caching, sku and storage url) to be used for Vmss"
  type = object({
    caching     = string
    sku         = string
    storage_url = string
  })
}

variable "web_data_disk" {
  description = "Additional disk details (logical unit number, size, sku, storage url) to be used for Vmss"
  type = list(object({
    lun         = number
    size        = number
    caching     = string
    sku         = string
    storage_url = string
  }))
}



variable "web_autoscale_name" {
  type = string
}

variable "web_autoscale_enabled" {
  type = bool
}


variable "web_notification" {
  type = object({
    name            = string
    send_to_admin   = bool
    send_to_coadmin = bool
    custom_emails   = list(string)
  })
}



########################## Load Balancer ################################


variable "lb_name" {
  type = string
}

variable "lb_sku" {
  type = string
}

variable "lb_pool" {
  type = list(string)
}

variable "lb_probe" {
  type = list(object({
    name         = string
    protocol     = string
    request_path = string
    port         = number
    interval     = number
    count        = number
  }))
}

variable "lb_rule" {
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



###################### APP VMSS #########################


variable "app_single_placement_group" {
  description = "if Single Placement Group will be enabled"
  type        = bool
}

variable "app_scale_set" {
  description = "Name, proximity placement group, health probe availability zone of Vmss "
  type = object({
    name     = string
    priority = string
    ppg_id   = string
    probe_id = string
    avzone   = list(string)
  })
}

variable "app_sku" {
  description = " size, tier and vm count of Vmss"
  type = object({
    size     = string
    tier     = string
    capacity = number
  })
}

variable "app_policy" {
  description = " policy details of upgrade mode, automatic_os, eviction_policy and over provisioned for VMss "
  type = object({
    upgrade       = string
    os            = bool
    eviction      = string
    overprovision = bool
  })
}

variable "app_vmss" {
  description = "User name and ssh key to be used for Vmss"
  type = object({
    user_name = string
  })
}

variable "app_os_image" {
  description = "Details of ID of custom image, publisher of image, offer(os flavour) of image, sku (os version) and version to be used for Vmss"
  type = object({
    id        = string
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "app_os_disk" {
  description = " Os Disk details (caching, sku and storage url) to be used for Vmss"
  type = object({
    caching     = string
    sku         = string
    storage_url = string
  })
}

variable "app_data_disk" {
  description = "Additional disk details (logical unit number, size, sku, storage url) to be used for Vmss"
  type = list(object({
    lun         = number
    size        = number
    caching     = string
    sku         = string
    storage_url = string
  }))
}


############################ APP VMSS AUTOSCALE ########################

variable "app_autoscale_name" {
  type = string
}

variable "app_autoscale_enabled" {
  type = bool
}


variable "app_notification" {
  type = object({
    name            = string
    send_to_admin   = bool
    send_to_coadmin = bool
    custom_emails   = list(string)
  })
}



#################### DATABASE ##################

variable "sqlserver_name" {
  description = "sqlserver name"
  type        = string
}


variable "sqlserver" {
  description = "sqlserver name, version and Login Id"
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

