locals {
  frontend_conf = flatten([
    for value in var.frontend_conf : {
      name                  = value.name
      subnet_id             = value.subnet_id
      private_ip            = value.private_ip != "" ? value.private_ip : null
      private_ip_allocation = value.private_ip != "" ? "static" : "dynamic"
      public_ip_id          = value.public_ip_id != "" ? value.public_ip_id : null
      avzone                = length(value.avzone) > 0 ? value.avzone : null
    }
  ])
  frontend_conf_map = {
    for value in local.frontend_conf : "${value.name}" => value
  }
  probe = flatten([
    for value in var.probe : {
      name         = value.name
      protocol     = value.protocol
      port         = value.port
      request_path = value.request_path != "" ? value.request_path : null
      interval     = value.interval != "" ? value.interval : null
      count        = value.count != "" ? value.count : null
    }
  ])
  probe_map = {
    for value in local.probe : "${value.name}" => value
  }
  rule = flatten([
    for value in var.rule : {
      name               = value.name
      protocol           = value.protocol
      frontend_port      = value.frontend_port
      backend_port       = value.backend_port
      frontend_conf_name = value.frontend_conf_name
      probe_name         = value.probe_name
      backend_pool_name  = value.backend_pool_name
      interval           = value.interval != "" ? value.interval : null
    }
  ])
  rule_map = {
    for value in local.rule : "${value.name}" => value
  }
  outbound = flatten([
    for value in var.outbound : {
      name                = value.name
      protocol            = value.protocol
      ports               = value.ports
      idle_timeout        = value.idle_timeout
      frontend_conf_names = value.frontend_conf_names
      backend_pool_name   = value.backend_pool_name
    }
  ])
  outbound_map = {
    for value in local.outbound : "${value.name}" => value
  }
}

resource "azurerm_lb" "lb" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  dynamic "frontend_ip_configuration" {
    for_each = local.frontend_conf_map
    iterator = object

    content {
      name                          = object.value.name
      subnet_id                     = object.value.subnet_id
      zones                         = object.value.avzone
      public_ip_address_id          = object.value.public_ip_id
      private_ip_address            = object.value.private_ip
      private_ip_address_allocation = object.value.private_ip_allocation
    }
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "pool" {
  for_each = {
    for value in var.pool : value => value
  }

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = each.value
}

resource "azurerm_lb_probe" "probe" {
  for_each = local.probe_map

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id

  name         = each.value.name
  protocol     = each.value.protocol
  request_path = each.value.request_path
  port         = each.value.port

  interval_in_seconds = each.value.interval
  number_of_probes    = each.value.count
}

resource "azurerm_lb_rule" "rule" {
  for_each = local.rule_map

  depends_on = [azurerm_lb_probe.probe, azurerm_lb_backend_address_pool.pool]

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id

  name          = each.value.name
  protocol      = each.value.protocol
  frontend_port = each.value.frontend_port
  backend_port  = each.value.backend_port

  frontend_ip_configuration_name = each.value.frontend_conf_name

  probe_id                = azurerm_lb_probe.probe[each.value.probe_name].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool[each.value.backend_pool_name].id
}

resource "azurerm_lb_outbound_rule" "outbound" {
  for_each = local.outbound_map

  depends_on = [azurerm_lb_backend_address_pool.pool]

  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.id

  name     = each.value.name
  protocol = each.value.protocol

  allocated_outbound_ports = each.value.ports
  idle_timeout_in_minutes  = each.value.idle_timeout

  backend_address_pool_id = azurerm_lb_backend_address_pool.pool[each.value.backend_pool_name].id

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_conf_names
    iterator = object

    content {
      name = object.value
    }
  }
}