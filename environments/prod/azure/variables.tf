variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the storage account."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Globally unique storage account name."
  type        = string
}

variable "account_replication_type" {
  description = "Replication type. Prod requires geo-redundancy."
  type        = string
  default     = "GZRS"

  validation {
    condition     = contains(["GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Production requires a geo-redundant replication type (GRS, RAGRS, GZRS, RAGZRS)."
  }
}

variable "versioning_enabled" {
  description = "Enable blob versioning. Must be true in prod."
  type        = bool
  default     = true

  validation {
    condition     = var.versioning_enabled == true
    error_message = "Blob versioning must be enabled in production."
  }
}

variable "lifecycle_rules" {
  description = "Blob lifecycle management rules (see module docs)."
  type        = any
  default     = {}
}

variable "customer_managed_key" {
  description = "Customer-managed key config. Required in production."
  type = object({
    key_vault_resource_id  = string
    key_name               = string
    key_version            = optional(string, null)
    user_assigned_identity = optional(object({ resource_id = string }), null)
  })

  validation {
    condition     = var.customer_managed_key != null
    error_message = "A customer-managed key (CMK) is mandatory in production."
  }
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
