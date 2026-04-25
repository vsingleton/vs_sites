resource "google_service_account" "tofu" {
  account_id   = "${var.project_name}-tofu"
  display_name = "OpenTofu service account"
  depends_on   = [google_project_service.iam]
}

# Storage admin covers bucket create/delete and IAM on buckets (needed for allUsers grants).
resource "google_project_iam_member" "tofu_storage" {
  project = var.gcp_project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.tofu.email}"
}

# loadBalancerAdmin covers backend buckets, URL maps, proxies, forwarding rules, and SSL certs.
resource "google_project_iam_member" "tofu_lb" {
  project = var.gcp_project
  role    = "roles/compute.loadBalancerAdmin"
  member  = "serviceAccount:${google_service_account.tofu.email}"
}

# networkAdmin is required to allocate global IP addresses.
resource "google_project_iam_member" "tofu_network" {
  project = var.gcp_project
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.tofu.email}"
}
