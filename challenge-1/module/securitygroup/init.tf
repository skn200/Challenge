terraform {
  backend "azurerm" {
    resource_group_name  = "TF-BKP-RG"
    storage_account_name = "tfstatebackupsa"
    container_name       = "tfstatebackup"
    access_key           = "MvEsyUwt3RDbrByxVqrVgnm22b2v5gMLwBDDOGqe01TzBwy/eWG8QGViY2qAUzHC5u/EQ6UstFnElzEvtLU5Gw=="
    key                  = "nsg-test1.tfstate"
  }
}


provider "azurerm" {
  version = "2.55.0"
  #version         = "=2.0.0"
  features {}

  #tenant_id       = var.tenant_id
  #client_id       = var.client_id
  #client_secret   = var.client_secret
  #subscription_id = var.subscription_id

  tenant_id       = "89359cf4-9e60-4099-80c4-775a0cfe27a7"
  subscription_id = "9540b342-9f94-4dd9-9eca-0698dda0107c"
  client_id       = "28f499a9-a9b6-4c41-a64c-8b68210a469c"
  client_secret   = "@MX1XREOIQWZPZ1O=P14?G-0CJ/z+tvb"
}