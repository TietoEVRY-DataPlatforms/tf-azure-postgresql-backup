locals {

  database_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.postgresql_resource_group_name}/providers/Microsoft.DBforPostgreSQL/servers/${var.postgresql_server_name}/databases/${var.postgresql_database_name}"
}

resource "azurerm_postgresql_firewall_rule" "postgresql_allow_azure_svc" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = module.identity_db.server_name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_data_protection_backup_policy_postgresql" "hub_noe_shared_bv_std_postgre_pol" {
  provider            = azurerm.shared
  name                = "dp-postgre-std-tst-pol"
  resource_group_name = data.azurerm_data_protection_backup_vault.az_bv_shared_noe.resource_group_name
  vault_name          = data.azurerm_data_protection_backup_vault.az_bv_shared_noe.name

  backup_repeating_time_intervals = ["R/2022-09-05T02:30:00+00:00/P1D"]

  default_retention_duration = "P6M"

  retention_rule {
    name     = "monthly"
    duration = "P6M"
    priority = 20
    criteria {
      absolute_criteria = "FirstOfWeek"
    }
  }
}

resource "azurerm_role_assignment" "rbac_postgresql_server_read" {
  scope                = var.hub_shared_resources_resourcegroup_name
  role_definition_name = "Reader"
  principal_id         = data.azurerm_data_protection_backup_vault.az_bv_shared_noe.identity.0.principal_id
}

resource "azurerm_role_assignment" "rbac_shared_keyvault_secrets_user" {
  scope                = data.azurerm_key_vault.hub_noe_keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_data_protection_backup_vault.az_bv_shared_noe.identity.0.principal_id
}

resource "azurerm_data_protection_backup_instance_postgresql" "bck_keycloak_db" {
  provider                                = azurerm.shared
  name                                    = "bck-keycloak-db-heimdall-eastnor-test-001"
  location                                = azurerm_resource_group.main.location
  vault_id                                = data.azurerm_data_protection_backup_vault.az_bv_shared_noe.id
  database_id                             = module.identity_db.databases.keycloak_db.id
  backup_policy_id                        = azurerm_data_protection_backup_policy_postgresql.hub_noe_shared_bv_std_postgre_pol.id
  database_credential_key_vault_secret_id = data.azurerm_key_vault_secret.kv_db_keycloak_db_secret.versionless_id
}
