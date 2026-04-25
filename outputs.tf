output "lb_ip_address" {
  value       = google_compute_global_address.website.address
  description = "Add an A record for each hostname in local.hostnames pointing to this IP. SSL cert will provision once DNS-01 validation TXT record is added."
}

output "website_buckets" {
  value       = { for k, v in google_storage_bucket.website : k => v.url }
  description = "GCS bucket URLs per hostname"
}

output "tofu_service_account" {
  value       = google_service_account.tofu.email
  description = "Service account email for automated tofu runs"
}
