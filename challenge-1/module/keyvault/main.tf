data "azurerm_client_config" "current" {}

resource "azurerm_user_assigned_identity" "agw" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "${var.appgw_name}-identity"
  tags                = var.tags
}

resource "azurerm_key_vault" "agw" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled        = var.keyvault.soft_delete_enabled
  soft_delete_retention_days = var.keyvault.soft_delete_retention
  purge_protection_enabled   = var.keyvault.purge_enabled
  sku_name                   = var.keyvault.sku

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}


resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.agw.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw.principal_id

  certificate_permissions = var.certificate_permission
}

resource "azurerm_key_vault_access_policy" "agw" {
  key_vault_id = azurerm_key_vault.agw.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.agw.principal_id

  secret_permissions = var.secret_permission
}

resource "azurerm_key_vault_certificate" "mysecret" {
  name         = var.certificate_name
  key_vault_id = azurerm_key_vault.agw.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = var.dns_names
      }

      subject            = "CN=${var.common-name}"
      validity_in_months = 12
    }
  }
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [azurerm_key_vault_certificate.mysecret]

  create_duration = "60s"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "keysecret" {
  name         = "${var.vmss_user}-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.apw.id
}