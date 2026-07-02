# Thin wrapper around the Google cloud-storage module.
# Upstream: terraform-google-modules/cloud-storage/google
# Registry: https://registry.terraform.io/modules/terraform-google-modules/cloud-storage/google/latest
#
# We surface versioning, lifecycle rules, and CMEK (encryption_key_names) and delegate the rest
# to the upstream module.

module "cloud_storage" {
  source  = "terraform-google-modules/cloud-storage/google"
  version = "~> 12.3"

  project_id = var.project_id
  location   = var.location
  prefix     = var.prefix
  names      = var.names

  storage_class = var.storage_class
  force_destroy = { for name in var.names : name => var.force_destroy }

  # Object versioning, keyed per bucket as the upstream module expects.
  versioning = { for name in var.names : name => var.versioning_enabled }

  # Lifecycle rules applied to every bucket.
  lifecycle_rules = var.lifecycle_rules

  # Customer-managed encryption keys (CMEK). Empty map => Google-managed keys.
  encryption_key_names = var.encryption_key_names

  labels = var.labels
}
