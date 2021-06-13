
resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "${var.prefix}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.retention_in_days

  tags = var.tags

}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name       = "${var.prefix}-log_analytics_solution_name"
  workspace_name      = "${var.prefix}-log-analytics-workspace"
  location            = var.location
  resource_group_name = var.resource_group_name
  #workspace_resource_id = var.workspace_resource_id
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id

  plan {
    publisher = var.solutions.publisher
    product   = var.solutions.product
  }
}