data "azurerm_client_config" "current" {}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "azurerm_mssql_server" "sqlserver" {
  name                         = var.sqlserver_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.sqlserver.db_version
  administrator_login          = var.sqlserver.admin_login_id
  administrator_login_password = random_password.password.result

  tags = var.tags

  #depends_on                       = [random_password.password]

}

#Create General Purpose elastic pool after sucessful SQL server creation
resource "azurerm_mssql_elasticpool" "sqlpool" {

  name                = var.sqlpool.name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_mssql_server.sqlserver.name
  license_type        = "LicenseIncluded"
  max_size_gb         = var.sqlpool.size

  sku {
    name     = var.sqlpool.sku_name
    tier     = var.sqlpool.tier
    family   = var.sqlpool.family
    capacity = var.sqlpool.capacity
  }

  per_database_settings {
    min_capacity = var.sqlpool.min_capacity
    max_capacity = var.sqlpool.max_capacity
  }
  #depends_on          = [azurerm_mssql_server.sqlserver]

  tags = var.tags
}


#Create SQL database under sql server and add it to elastic pool
resource "azurerm_mssql_database" "sqldb" {

  name            = var.sqldb.name
  server_id       = azurerm_mssql_server.sqlserver.id
  elastic_pool_id = azurerm_mssql_elasticpool.sqlpool.id
  max_size_gb     = var.sqldb.size

  tags = var.tags

  #depends_on          = [azurerm_mssql_elasticpool.sqlpool]
}


resource "azurerm_mssql_virtual_network_rule" "sqlvnetrule" {
  name      = var.sqlvnetrule_name
  server_id = azurerm_mssql_server.sqlserver.id
  subnet_id = var.sqlvnetrule_subnet_id
}

resource "azurerm_key_vault" "sqldb" {
  name                = "${var.sqlserver_name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "keyscret" {
  name         = "${var.sqlserver_name}-secret"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.sqldb.id
}