locals {
  frontend_port = flatten([
    for value in var.frontend_port : {
      name = value.name
      port = value.port
    }
  ])
  frontend_port_map = {
    for value in local.frontend_port : "${value.name}" => value
  }
  frontend_conf = flatten([
    for value in var.frontend_conf : {
      name                  = value.name
      subnet_id             = value.subnet_id
      private_ip            = value.private_ip != "" ? value.private_ip : null
      private_ip_allocation = value.private_ip != "" ? "static" : "dynamic"
      public_ip_id          = value.public_ip_id != "" ? value.public_ip_id : null
    }
  ])
  frontend_conf_map = {
    for value in local.frontend_conf : "${value.name}" => value
  }
  backend_pool = flatten([
    for value in var.backend_pool : {
      name  = value.name
      fqdns = length(value.fqdns) > 0 ? value.fqdns : null
      ips   = length(value.ips) > 0 ? value.ips : null
    }
  ])
  backend_pool_map = {
    for value in local.backend_pool : "${value.name}" => value
  }
  probe = flatten([
    for value in var.probe : {
      name     = value.name
      protocol = value.protocol
      path     = value.path
      host     = value.host
      interval = value.interval != "" ? value.interval : null
      timeout  = value.timeout != "" ? value.timeout : null
      count    = value.count != "" ? value.count : null
    }
  ])
  probe_map = {
    for value in local.probe : "${value.name}" => value
  }
  listener = flatten([
    for value in var.listener : {
      name               = value.name
      frontend_conf_name = value.frontend_conf_name
      frontend_port_name = value.frontend_port_name
      protocol           = value.protocol
      host               = value.host != "" ? value.host : null
      sni                = value.sni
      ssl_cert_name      = value.ssl_cert_name != "" ? value.ssl_cert_name : null
    }
  ])
  listener_map = {
    for value in local.listener : "${value.name}" => value
  }
  rule = flatten([
    for value in var.rule : {
      name                 = value.name
      type                 = value.type != "" ? value.type : "Basic"
      listener_name        = value.listener_name
      backend_pool_name    = value.backend_pool_name
      backend_setting_name = value.backend_setting_name
    }
  ])
  rule_map = {
    for value in local.rule : "${value.name}" => value
  }
  backend_setting = flatten([
    for value in var.backend_setting : {
      name        = value.name
      cookie_name = value.cookie_name
      port        = value.port
      protocol    = value.protocol
      timeout     = value.timeout
      probe_name  = value.probe_name
      host        = value.host
      drain_time  = value.drain_time
    }
  ])
  backend_setting_map = {
    for value in local.backend_setting : "${value.name}" => value
  }
  ssl_cert = flatten([
    for value in var.ssl_cert : {
      name                = value.name
      data                = value.data != "" ? value.data : null
      password            = value.password != "" ? value.password : null
      key_vault_secret_id = value.key_vault_secret_id != "" ? value.key_vault_secret_id : null
    }
  ])
  ssl_cert_map = {
    for value in local.ssl_cert : "${value.name}" => value
  }

  gateway_ip_conf = flatten([
    for value in var.gateway_ip_conf : {
      name      = value.name
      subnet_id = value.subnet_id
    }
  ])
  gateway_ip_conf_map = {
    for value in local.gateway_ip_conf : "${value.name}" => value
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  enable_http2        = var.enable_http2

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity != 0 ? var.sku.capacity : null
  }

  identity {
    type         = var.identity.type != "" ? var.identity.type : null
    identity_ids = var.identity.ids != "" ? var.identity.ids : null
  }

  lifecycle {
    ignore_changes = [
      identity
    ]
  }

  dynamic "ssl_certificate" {
    for_each = local.ssl_cert_map
    iterator = object

    content {
      name                = object.value.name
      data                = object.value.data
      password            = object.value.password
      key_vault_secret_id = object.value.key_vault_secret_id
    }
  }

  dynamic "gateway_ip_configuration" {
    for_each = local.gateway_ip_conf_map
    iterator = object

    content {
      name      = object.value.name
      subnet_id = object.value.subnet_id
    }
  }

  dynamic "frontend_port" {
    for_each = local.frontend_port_map
    iterator = object

    content {
      name = object.value.name
      port = object.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = local.frontend_conf_map
    iterator = object

    content {
      name                          = object.value.name
      subnet_id                     = object.value.subnet_id
      public_ip_address_id          = object.value.public_ip_id
      private_ip_address            = object.value.private_ip
      private_ip_address_allocation = object.value.private_ip_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = local.backend_pool_map
    iterator = object

    content {
      name         = object.value.name
      fqdns        = object.value.fqdns
      ip_addresses = object.value.ips
    }
  }

  dynamic "backend_http_settings" {
    for_each = local.backend_setting_map
    iterator = object

    content {
      name                  = object.value.name
      cookie_based_affinity = object.value.cookie_name != "" ? "Enabled" : "Disabled"
      affinity_cookie_name  = object.value.cookie_name != "" ? object.value.cookie_name : null
      port                  = object.value.port
      protocol              = object.value.protocol
      request_timeout       = object.value.timeout
      probe_name            = object.value.probe_name
      host_name             = object.value.host

      dynamic "connection_draining" {
        for_each = object.value.drain_time != 0 ? [object.value.drain_time] : []
        iterator = object_inner

        content {
          enabled           = true
          drain_timeout_sec = object_inner.value
        }
      }
    }
  }

  dynamic "probe" {
    for_each = local.probe_map
    iterator = object

    content {
      name                = object.value.name
      interval            = object.value.interval
      path                = object.value.path
      protocol            = object.value.protocol
      timeout             = object.value.timeout
      unhealthy_threshold = object.value.count
      host                = object.value.host != "" ? object.value.host : "127.0.0.1"
    }
  }

  dynamic "http_listener" {
    for_each = local.listener_map
    iterator = object

    content {
      name                           = object.value.name
      frontend_ip_configuration_name = object.value.frontend_conf_name
      frontend_port_name             = object.value.frontend_port_name
      protocol                       = object.value.protocol
      host_name                      = object.value.host
      require_sni                    = object.value.sni
      ssl_certificate_name           = object.value.ssl_cert_name
    }
  }

  dynamic "request_routing_rule" {
    for_each = local.rule_map
    iterator = object

    content {
      name                       = object.value.name
      rule_type                  = object.value.type
      http_listener_name         = object.value.listener_name
      backend_address_pool_name  = object.value.backend_pool_name
      backend_http_settings_name = object.value.backend_setting_name
    }
  }

  dynamic "autoscale_configuration" {
    for_each = var.sku.capacity == 0 ? { "autoscale" = var.autoscale } : {}
    iterator = object

    content {
      min_capacity = object.value.min
      max_capacity = object.value.max
    }
  }

  tags = var.tags
}