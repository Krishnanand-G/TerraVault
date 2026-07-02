terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "storage" {
  source = "../../../modules/azure_storage"

  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_replication_type = var.account_replication_type

  versioning_enabled = var.versioning_enabled
  lifecycle_rules    = var.lifecycle_rules

  # CMK is optional in dev.
  customer_managed_key = var.customer_managed_key

  tags = merge({
    environment = "dev"
    platform    = "terravault"
  }, var.tags)
}
