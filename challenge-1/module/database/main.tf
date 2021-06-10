resource "azurerm_sql_server" "master" {
    name                           = var.master_database.name
    resource_group_name            = var.resource_group.name
    location                       = var.resource_group.location
    version                        = var.master_database.version
    administrator_login            = var.master_database.admin
    administrator_login_password   = var.master_database.password
}

resource "azurerm_sql_database" "db" {
  name                  = "db"
  resource_group_name   = var.resource_group.name
  location              = var.resource_group.location
  server_name           = azurerm_sql_server.master.name
}