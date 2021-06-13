provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
}


###################### NETWORK #######################

module "network" {

  source = "./module/network"

  network-rg-name    = var.network-rg-name
  location           = var.location
  vnet-name          = var.vnet-name
  vnet-address-space = var.vnet-address-space
  subnet             = var.subnet

}

########################## LOG ANALYTICS ###############

module "loganalytics" {

  source = "./module/loganalytics"

  prefix                      = var.prefix
  resource_group_name         = var.resource_group_name
  location                    = var.location
  retention_in_days           = var.retention_in_days
  log_analytics_workspace_sku = var.log_analytics_workspace_sku
  solutions                   = var.solutions
  tags                        = var.tags

}

######################### KEY VAULT #######################

module "keyvault" {

  source = "./module/keyvault"

  resource_group_name = var.resource_group_name
  location            = var.location

  appgw_name             = var.appgw_name
  keyvault_name          = var.keyvault_name
  keyvault               = var.keyvault
  certificate_permission = var.certificate_permission
  secret_permission      = var.secret_permission
  certificate_name       = var.certificate_name
  dns_names              = var.dns_names
  common-name            = var.common_name
  vmss_user              = var.vmss_user
  tags                   = var.tags

}


####################### APP GATEWAY ##########################


resource "azurerm_public_ip" "appgw-pub-ip" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name              = "${var.appgw_name}-pubip"
  allocation_method = "Static"
  sku               = "Standard"
  tags = {
    "compliance" = "regulated"
    "zone"       = "private"
  }
}



module "appgw" {

  source = "./module/appgw"

  depends_on = [module.loganalytics.workspace, module.keyvault.mysecret, module.keyvault.identity]

  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = module.loganalytics.workspace.id
  enable_http2               = true
  name                       = var.appgw_name
  sku                        = var.appgw_sku
  autoscale                  = var.appgw_autoscale
  gateway_ip_conf = [
    {
      name      = "gateway-ip-conf-1"
      subnet_id = module.network.subnet["appgw-subnet"].id
    }
  ]

  ssl_cert = [
    {
      name                = "web01-com"
      data                = ""
      password            = ""
      key_vault_secret_id = module.keyvault.mysecret.secret_id
    }
  ]

  identity = {
    type = "UserAssigned"
    ids  = [module.keyvault.identity.id]
  }

  frontend_conf = [
    {
      name         = "appGwPublicFrontendIp"
      subnet_id    = ""
      private_ip   = ""
      public_ip_id = azurerm_public_ip.appgw-pub-ip.id
    }
  ]

  frontend_port = var.appgw_frontend_port

  backend_pool = var.appgw_backend_pool

  probe = var.appgw_probe

  backend_setting = [
    {
      name                 = "http"
      subnet_id            = module.network.subnet["appgw-subnet"].id
      cookie_name          = ""
      port                 = 80
      protocol             = "Http"
      timeout              = 20
      probe_name           = "probe-1"
      drain_time           = 60
      host                 = ""
      affinity_cookie_name = ""
    }
  ]

  listener = var.appgw_listener
  rule     = var.appgw_rule
  tags     = var.tags


}

########################## WEB VMSS ######################

module "web" {

  source = "./module/compute"

  resource_group_name = var.resource_group_name
  location            = var.location

  single_placement_group = var.web_single_placement_group
  scale_set              = var.web_scale_set
  identity = {
    system      = false
    user_id_ids = [""]
  }
  sku      = var.web_sku
  policy   = var.web_policy
  os_image = var.web_os_image
  os_disk  = var.web_os_disk

  nic = {
    subnet_id      = module.network.subnet["web-subnet"].id
    nsg_id         = ""
    pub_ip         = false
    accelerated    = true
    ipforward      = false
    appgw_pool_ids = [module.appgw.app_gateway.pool["pool-1"].id]
    lb_pool_ids    = []
  }

  root = {
    user_name = var.web_vmss.user_name
    password   = module.keyvault.password.secret_id
  }

  data_disk = var.web_data_disk
  tags      = var.tags

}

######################### WEB VMSS AUTOSCALE ###################################

module "web-autoscale" {

  source = "./module/autoscale"

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.web_autoscale_name
  target_id           = module.web.scale_set.id
  enabled             = var.web_autoscale_enabled
  notification        = var.web_notification

  profile = [
    {
      name = "scale-up"

      capacity = {
        default = 3
        min     = 2
        max     = 5
      }

      rule = [
        {
          name = "cpu-scaleup-1"
          trigger = {
            name             = "Percentage CPU"
            target_id        = module.app.scale_set.id
            operator         = "GreaterThan"
            statistic        = "Average"
            threshold        = "50"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT10M"
          }
          action = {
            cooldown  = "PT5M"
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
          }
        },
        {
          name = "cpu-scaledown-1"
          trigger = {
            name             = "Percentage CPU"
            target_id        = module.app.scale_set.id
            operator         = "LessThanOrEqual"
            statistic        = "Average"
            threshold        = "40"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT10M"
          }
          action = {
            cooldown  = "PT5M"
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
          }
        }
      ]
    }
  ]

  tags = var.tags
}




######################## LOAD BALANCER #######################

module "lb" {

  source = "./module/loadbalancer"

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.lb_name
  sku                 = var.lb_sku

  frontend_conf = [
    {
      name         = "frontend-conf-1"
      subnet_id    = module.network.subnet["lb-subnet"].id
      private_ip   = ""
      public_ip_id = ""
      avzone       = ["1"]
    }
  ]

  pool     = var.lb_pool
  probe    = var.lb_probe
  rule     = var.lb_rule
  outbound = []

  tags = var.tags
}


######################## APP VMSS ###############################

module "app" {

  source = "./module/compute"

  resource_group_name = var.resource_group_name
  location            = var.location

  single_placement_group = var.app_single_placement_group
  scale_set              = var.app_scale_set
  identity = {
    system      = false
    user_id_ids = [""]
  }
  sku      = var.app_sku
  policy   = var.app_policy
  os_image = var.app_os_image
  os_disk  = var.app_os_disk

  nic = {
    subnet_id      = module.network.subnet["app-subnet"].id
    nsg_id         = ""
    pub_ip         = false
    accelerated    = true
    ipforward      = false
    appgw_pool_ids = []
    lb_pool_ids    = [module.lb.load_balancer.pool["pool-1"].id]
  }

  root = {
    user_name = var.app_vmss.user_name
    password   = module.keyvault.password.secret_id
  }

  data_disk = var.app_data_disk
  tags      = var.tags

}

############################# APP VMSS AUTOSCALE ############################

module "app-autoscale" {

  source = "./module/autoscale"

  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.app_autoscale_name
  target_id           = module.app.scale_set.id
  enabled             = var.app_autoscale_enabled
  notification        = var.app_notification

  profile = [
    {
      name = "scale-up"

      capacity = {
        default = 3
        min     = 2
        max     = 5
      }

      rule = [
        {
          name = "cpu-scaleup-1"
          trigger = {
            name             = "Percentage CPU"
            target_id        = module.app.scale_set.id
            operator         = "GreaterThan"
            statistic        = "Average"
            threshold        = "50"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT10M"
          }
          action = {
            cooldown  = "PT5M"
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
          }
        },
        {
          name = "cpu-scaledown-1"
          trigger = {
            name             = "Percentage CPU"
            target_id        = module.app.scale_set.id
            operator         = "LessThanOrEqual"
            statistic        = "Average"
            threshold        = "40"
            time_aggregation = "Average"
            time_grain       = "PT1M"
            time_window      = "PT10M"
          }
          action = {
            cooldown  = "PT5M"
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
          }
        }
      ]
    }
  ]

  tags = var.tags

}

########################## DATABASE ###########################

module "database" {
  source = "./module/database"

  resource_group_name   = var.resource_group_name
  location              = var.location
  sqlserver_name        = var.sqlserver_name
  sqlserver             = var.sqlserver
  sqlpool               = var.sqlpool
  sqldb                 = var.sqldb
  sqlvnetrule_name      = var.sqlvnetrule_name
  sqlvnetrule_subnet_id = module.network.subnet["app-subnet"].id

  tags = var.tags

}
