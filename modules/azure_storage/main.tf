# Native azurerm wrapper for TerraVault storage accounts.
# Inspired by Azure/avm-res-storage-storageaccount input patterns.

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  blob_properties {
    versioning_enabled = var.versioning_enabled
  }

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      key_vault_key_id          = "${customer_managed_key.value.key_vault_resource_id}/keys/${customer_managed_key.value.key_name}"
      user_assigned_identity_id = try(customer_managed_key.value.user_assigned_identity.resource_id, null)
    }
  }

  tags = var.tags
}

resource "azurerm_storage_management_policy" "this" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = try(rule.value.enabled, true)

      dynamic "filters" {
        for_each = [try(rule.value.filters, { blob_types = ["blockBlob"] })]
        content {
          blob_types = filters.value.blob_types
        }
      }

      dynamic "actions" {
        for_each = [rule.value.actions]
        content {
          dynamic "base_blob" {
            for_each = try([actions.value.base_blob], [])
            content {
              tier_to_cool_after_days_since_modification_greater_than    = try(base_blob.value.tier_to_cool_after_days_since_modification_greater_than, null)
              delete_after_days_since_modification_greater_than        = try(base_blob.value.delete_after_days_since_modification_greater_than, null)
            }
          }
        }
      }
    }
  }
}
