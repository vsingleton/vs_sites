resource "google_storage_bucket" "tfstate" {
  name                        = "${var.project_name}-tfstate"
  location                    = "US"
  uniform_bucket_level_access = true
  force_destroy               = false
  labels                      = local.labels

  versioning {
    enabled = true
  }
}
