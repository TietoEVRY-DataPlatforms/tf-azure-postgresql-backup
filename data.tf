
#Lookup of Shared HUB Keyvault to place ADO secret
data "azurerm_key_vault" "hub_noe_keyvault" {
  provider            = azurerm.shared
  name                = var.hub_keyvault_name
  resource_group_name = var.hub_shared_resources_resourcegroup_name
}
#Lookup of created ADO secret in shared Keyvault
data "azurerm_key_vault_secret" "kv_db_keycloak_db_secret" {
  provider     = azurerm.shared
  name         = "dp-postgre-heimdall-test-keycloak-db"
  key_vault_id = data.azurerm_key_vault.hub_noe_keyvault.id
}

#Lookup of shared Azure backup vault
data "azurerm_data_protection_backup_vault" "az_bv_shared_noe" {
  provider            = azurerm.shared
  name                = "bv-hub-eastnor-prod-shared-001"
  resource_group_name = "rg-hub-eastnor-prod-shared"
}

#Lookup of stored PostgreSQL credentials
data "vault_generic_secret" "postgresql_admin_secret_vault" {
  path = "secret/heimdall/databases/qa/psql-heimdall-eastnor-qa-002"
}

#Lookup of stored PostgreSQL credentials if its on keyvault
data "azurerm_key_vault_secret" "kv_db_keycloak_db_secret" {
  provider     = azurerm.shared
  name         = "dp-postgre-heimdall-test-keycloak-db"
  key_vault_id = data.azurerm_key_vault.hub_noe_keyvault.id
}

#Lookup of the PostgreServer
data "azurerm_postgresql_server" "example" {
  name                = var.postgresql_server_name
  resource_group_name = var.postgresql_resource_group_name
}
