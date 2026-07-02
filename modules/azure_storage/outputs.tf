output "id" {
  description = "Resource ID of the storage account."
  value       = module.storage_account.resource_id
}

output "name" {
  description = "Name of the storage account."
  value       = var.name
}

output "resource" {
  description = "The full storage account resource object exported by the upstream AVM module."
  value       = module.storage_account.resource
  sensitive   = true
}
