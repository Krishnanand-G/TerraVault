output "bucket_names" {
  description = "Map of short name => full bucket name created by the upstream module."
  value       = module.cloud_storage.names
}

output "buckets" {
  description = "Map of bucket resources exported by the upstream module."
  value       = module.cloud_storage.buckets
}

output "urls" {
  description = "Map of short name => bucket gs:// URL."
  value       = module.cloud_storage.urls
}
