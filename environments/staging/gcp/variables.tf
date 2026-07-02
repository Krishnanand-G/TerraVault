variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "region" {
  description = "Default provider region."
  type        = string
  default     = "us-central1"
}

variable "location" {
  description = "Bucket location."
  type        = string
  default     = "US"
}

variable "prefix" {
  description = "Prefix for bucket names."
  type        = string
  default     = "terravault-staging"
}

variable "bucket_names" {
  description = "List of bucket suffixes to create."
  type        = list(string)
  default     = ["data"]
}

variable "storage_class" {
  description = "Default storage class."
  type        = string
  default     = "STANDARD"
}

variable "versioning_enabled" {
  description = "Enable object versioning."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "Lifecycle rules (see module docs)."
  type = list(object({
    action    = map(string)
    condition = map(string)
  }))
  default = []
}

variable "encryption_key_names" {
  description = "Map of bucket name => KMS key self link (CMEK). Empty => Google-managed."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels."
  type        = map(string)
  default     = {}
}
