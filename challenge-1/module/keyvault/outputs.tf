output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.agw.id
}

output "name" {
  description = "Name of key vault created."
  value       = azurerm_key_vault.agw.name
}

output "vault_uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.agw.vault_uri
}

output "mysecret" {
  value = azurerm_key_vault_certificate.mysecret.secret_id
}

output "identity" {
  value = azurerm_user_assigned_identity.agw.id
}

output "password" {
  value = azurerm_key_vault_secret.mysecret.secret_id
}