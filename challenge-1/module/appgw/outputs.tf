output "app_gateway" {
  value = {
    id   = azurerm_application_gateway.appgw.id
    name = var.name
    pool = {
      for key, value in var.backend_pool : value.name => {
        id   = azurerm_application_gateway.appgw.backend_address_pool[key].id
        name = value.name
      }
    }
  }
}