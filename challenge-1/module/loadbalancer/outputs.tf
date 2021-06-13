output "load_balancer" {
  value = {
    id   = azurerm_lb.lb.id
    name = var.name
    frontend_conf = {
      for key, value in azurerm_lb.lb.frontend_ip_configuration : value.name => {
        id                    = value.id
        name                  = value.name
        public_ip_id          = value.public_ip_address_id
        private_ip            = value.private_ip_address
        private_ip_allocation = value.private_ip_address_allocation
      }
    }
    pool = {
      for key, value in azurerm_lb_backend_address_pool.pool : value.name => {
        id   = value.id
        name = value.name
      }
    }
    probe = {
      for key, value in azurerm_lb_probe.probe : value.name => {
        id   = value.id
        name = value.name
      }
    }
    rule = {
      for key, value in azurerm_lb_rule.rule : value.name => {
        id   = value.id
        name = value.name
      }
    }
    outbound = {
      for key, value in azurerm_lb_outbound_rule.outbound : value.name => {
        id   = value.id
        name = value.name
      }
    }
  }
}