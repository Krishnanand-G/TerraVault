terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "storage" {
  source = "../../../modules/gcs_storage"

  project_id = var.project_id
  location   = var.location
  prefix     = var.prefix
  names      = var.bucket_names

  storage_class      = var.storage_class
  versioning_enabled = var.versioning_enabled
  lifecycle_rules    = var.lifecycle_rules

  encryption_key_names = var.encryption_key_names

  labels = merge({
    environment = "staging"
    platform    = "terravault"
  }, var.labels)
}
