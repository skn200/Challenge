
resource_group_name = "my-test-rg"
location            = "eastus"


##################################### NETWORK ###########################################

network-rg-name    = "vnet-rg-eastus"
vnet-name          = "myproject-vnet"
vnet-address-space = ["10.0.0.0/16"]

subnet = [
  {
    name      = "appgw-subnet"
    prefix    = ["10.0.0.0/24"]
    endpoints = []
  },
  {
    name      = "bastion-subnet"
    prefix    = ["10.0.1.0/24"]
    endpoints = []
  },
  {
    name      = "lb-subnet"
    prefix    = ["10.0.2.0/24"]
    endpoints = []
  },
  {
    name      = "web-subnet"
    prefix    = ["10.0.3.0/24"]
    endpoints = []
  },
  {
    name      = "app-subnet"
    prefix    = ["10.0.4.0/24"]
    endpoints = []
  },
  {
    name      = "db-subnet"
    prefix    = ["10.0.5.0/24"]
    endpoints = []
  }
]


########################### SECURITY GROUPS ###########

bastion_subnet_cidr         = "10.0.1.0/24"
web_subnet_cidr             = "10.0.3.0/24"
app_subnet_cidr             = "10.0.4.0/24"
appgw_subnet_cidr           = "10.0.0.0/24"


########################### BASTION ####################

bastion_hostname            = "bastion_host"


############################ LOG ANALYTICS ##############


prefix                      = "appgw"
retention_in_days           = "30"
log_analytics_workspace_sku = "PerGB2018"
solutions = {
  publisher = "Microsoft"
  product   = "OMSGallery/AzureAppGatewayAnalytics"
}


######################## KEY VAULT #################################

keyvault_name = "appgw-keyvault"
keyvault = {
  name                  = "kvtestsite2"
  soft_delete_enabled   = true
  soft_delete_retention = 7
  purge_enabled         = false
  sku                   = "standard"
}

vmss_user              = "vmss-kv-user"
certificate_permission = ["Create", "Get", "List"]
secret_permission      = ["get"]
certificate_name       = "web01-com"
dns_names              = ["web01.com"]
common_name            = "web01.com"

########################## APP GATEWAY ###########################

appgw_name   = "appgw-web"
enable_http2 = false
appgw_sku = {
  name     = "Standard_v2"
  tier     = "Standard_v2"
  capacity = 0
}
appgw_autoscale = {
  min = 2
  max = 4
}

appgw_frontend_port = [
  {
    name = "http"
    port = "80"
  },
  {
    name = "https"
    port = "443"
  }
]

appgw_backend_pool = [
  {
    name  = "pool-1"
    fqdns = []
    ips   = []
  }
]


appgw_probe = [
  {
    name     = "probe-lbstatus-01"
    protocol = "Http"
    path     = "/"
    interval = 10
    timeout  = 5
    count    = 2
    host     = "127.0.0.1"
  },
]

appgw_listener = [
  {
    name               = "listner-http",
    frontend_conf_name = "appGwPublicFrontendIp"
    frontend_port_name = "http"
    protocol           = "Http"
    host               = ""
    sni                = false
    ssl_cert_name      = ""
  },
  {
    name               = "listener-https",
    frontend_conf_name = "appGwPublicFrontendIp"
    frontend_port_name = "https"
    protocol           = "Https"
    host               = ""
    sni                = false
    ssl_cert_name      = "web01-com"
  }
]


appgw_rule = [
  {
    name                 = "rule-http"
    type                 = "Basic"
    listener_name        = "listener-http"
    backend_pool_name    = "web-backend-pool"
    backend_setting_name = "http"
  },
  {
    name                 = "rule-https"
    type                 = "Basic"
    listener_name        = "listener-https"
    backend_pool_name    = "web-backend-pool"
    backend_setting_name = "http"
  },
]

############################ WEB VMSS ###############################

web_single_placement_group = false

web_scale_set = {
  name     = "web01-vmss"
  priority = "Regular"
  ppg_id   = ""
  probe_id = ""
  avzone   = ["1"]
}

web_sku = {
  size     = "Standard_F8s_v2"
  tier     = "Standard"
  capacity = 2
}

web_policy = {
  upgrade       = "Manual"
  os            = false
  overprovision = true
  eviction      = ""
}
web_os_image = {
  id        = ""
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}
web_vmss = {
  user_name = "adminuser"
}

web_os_disk = {
  caching     = "ReadWrite"
  sku         = "Premium_LRS"
  storage_url = ""
}

web_data_disk = [
  {
    lun         = 0
    size        = 512
    caching     = "None"
    sku         = "Standard_LRS"
    storage_url = ""
  }
]

###################### WEB VMSS AUTOSCALE ##################################

web_autoscale_name    = "web-autoscale"
web_autoscale_enabled = true

web_notification = {
  name            = "autoscale"
  send_to_admin   = false
  send_to_coadmin = false
  custom_emails   = []
  webhook         = []
}

################################### LOAD BALANCER #############################

lb_name = "lb-app"
lb_sku  = "Standard"
lb_pool = [
  "pool-1"
]

lb_probe = [
  {
    name         = "probe-1"
    protocol     = "Http"
    request_path = "/geoservice/ping"
    port         = 8080
    interval     = 10
    count        = 3
  }
]

lb_rule = [
  {
    name               = "rule-1"
    protocol           = "Tcp"
    frontend_port      = 8080
    backend_port       = 8080
    frontend_conf_name = "frontend-conf-1"
    probe_name         = "probe-1"
    backend_pool_name  = "pool-1"
    interval           = 30
  }
]


############################# APP VMSS ###########################


app_single_placement_group = false

app_scale_set = {
  name     = "web01-vmss"
  priority = "Regular"
  ppg_id   = ""
  probe_id = ""
  avzone   = ["1"]
}

app_sku = {
  size     = "Standard_F8s_v2"
  tier     = "Standard"
  capacity = 2
}

app_policy = {
  upgrade       = "Manual"
  os            = false
  overprovision = true
  eviction      = ""
}
app_os_image = {
  id        = ""
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "18.04-LTS"
  version   = "latest"
}
app_vmss = {
  user_name = "adminuser"
}

app_os_disk = {
  caching     = "ReadWrite"
  sku         = "Premium_LRS"
  storage_url = ""
}

app_data_disk = [
  {
    lun         = 0
    size        = 512
    caching     = "None"
    sku         = "Standard_LRS"
    storage_url = ""
  }
]


###################### APP VMSS AUTOSCALE ##############

app_autoscale_name    = "app-autoscale"
app_autoscale_enabled = true

app_notification = {
  name            = "autoscale"
  send_to_admin   = false
  send_to_coadmin = false
  custom_emails   = []
  webhook         = []
}




######################## DATABASE #########################

sqlserver_name = "mysqlserver01"
sqlserver = {
  db_version     = "12.0"
  admin_login_id = "sqladmin"
}

sqlpool = {
  name         = "pool1"
  size         = "70"
  sku_name     = "GP_Gen5"
  tier         = "GeneralPurpose"
  family       = "Gen5"
  capacity     = "4"
  min_capacity = "0.25"
  max_capacity = "4"
}

sqldb = {
  name = "sqldb1"
  size = "100"
}

sqlvnetrule_name = "sqlvnetrule1"
