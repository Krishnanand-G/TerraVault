variable "name" {
  description = "Name of the storage account (3-24 lowercase alphanumeric characters, globally unique)."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the storage account."
  type        = string
}

variable "location" {
  description = "Azure region for the storage account."
  type        = string
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)."
  type        = string
  default     = "GRS"
}

variable "versioning_enabled" {
  description = "Enable blob versioning on the storage account."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = <<-EOT
    Map of blob lifecycle management rules passed to the AVM storage_management_policy_rule.
    Each rule follows the upstream schema (name, enabled, filters, actions). Leave empty to skip
    creating a management policy.
  EOT
  type        = any
  default     = {}
}

variable "customer_managed_key" {
  description = <<-EOT
    Customer-managed key (CMK) configuration for encryption at rest. Set to null to use
    Microsoft-managed keys. When provided, supply the Key Vault key details as expected by the
    upstream AVM module's customer_managed_key object.
  EOT
  type = object({
    key_vault_resource_id  = string
    key_name               = string
    key_version            = optional(string, null)
    user_assigned_identity = optional(object({ resource_id = string }), null)
  })
  default = null
}

variable "tags" {
  description = "Tags to apply to the storage account."
  type        = map(string)
  default     = {}
}
