output "scale_set" {
  value = {
    id   = azurerm_virtual_machine_scale_set.vmss.id
    name = var.scale_set.name
  }
}