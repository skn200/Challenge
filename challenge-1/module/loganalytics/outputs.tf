output "workspace" {
  value = azurerm_log_analytics_workspace.workspace.id
}

output "name" {
  value = azurerm_log_analytics_workspace.workspace.name
}

output "solution" {
  value = azurerm_log_analytics_solution.solution.id
}