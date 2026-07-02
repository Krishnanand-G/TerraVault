variable "project_id" {
  description = "GCP project ID in which to create the buckets."
  type        = string
}

variable "location" {
  description = "Location for the buckets (e.g. US, EU, or a specific region like us-central1)."
  type        = string
}

variable "prefix" {
  description = "Prefix prepended to each bucket name. Combined with names to form globally unique bucket names."
  type        = string
  default     = ""
}

variable "names" {
  description = "List of bucket (suffix) names to create."
  type        = list(string)
}

variable "storage_class" {
  description = "Default storage class for the buckets (STANDARD, NEARLINE, COLDLINE, ARCHIVE)."
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Enable object versioning. Applied to every bucket in `names`."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = <<-EOT
    List of lifecycle rules passed straight through to the upstream module's `lifecycle_rules`
    input. Each element has `action` and `condition` objects following the google_storage_bucket
    schema. Leave empty for no lifecycle rules.
  EOT
  type = list(object({
    action    = map(string)
    condition = map(string)
  }))
  default = []
}

variable "encryption_key_names" {
  description = <<-EOT
    Map of bucket name => Cloud KMS key self link used for customer-managed encryption (CMEK).
    Leave empty to use Google-managed encryption keys.
  EOT
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Allow Terraform to destroy buckets that still contain objects."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels applied to all buckets."
  type        = map(string)
  default     = {}
}
