# tf-azure-postgresql-backup

The purpose of this Terraform module is to add a PostgreSQL Database to Azure backup vault.

Assumptions:
Your environment is running a Hub/Spoke / Landingzone architecture where it is assumed that services like Keyvault, Azure Backup Vault, Vault is running as a shared service.

Also in our environment we use Vault to store PostgreSQL credentials.