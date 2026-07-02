# Thin wrapper around the Azure Verified Module (AVM) for storage accounts.
# Upstream: Azure/avm-res-storage-storageaccount/azurerm
# Registry: https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest
#
# We only surface the knobs TerraVault cares about (versioning, lifecycle rules,
# customer-managed keys) and delegate everything else to the upstream module.

module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.7"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Blob versioning is configured through the blob_properties block upstream.
  blob_properties = {
    versioning_enabled = var.versioning_enabled
  }

  # Blob lifecycle management policy rules (empty map => no policy created).
  storage_management_policy_rule = var.lifecycle_rules

  # Customer-managed key (CMK). Null => Microsoft-managed keys.
  customer_managed_key = var.customer_managed_key

  tags = var.tags
}
