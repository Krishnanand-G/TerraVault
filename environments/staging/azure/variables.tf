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
  description = "Replication type."
  type        = string
  default     = "GRS"
}

variable "versioning_enabled" {
  description = "Enable blob versioning."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Blob lifecycle management rules (see module docs)."
  type        = any
  default     = {}
}

variable "customer_managed_key" {
  description = "Customer-managed key config (null => Microsoft-managed)."
  type = object({
    key_vault_resource_id  = string
    key_name               = string
    key_version            = optional(string, null)
    user_assigned_identity = optional(object({ resource_id = string }), null)
  })
  default = null
}

variable "tags" {
  description = "Additional tags."
  type        = map(string)
  default     = {}
}
