resource "google_storage_bucket" "website" {
  for_each = toset(local.hostnames)

  name                        = each.key
  location                    = "US"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.labels

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "website_public" {
  for_each = toset(local.hostnames)

  bucket = google_storage_bucket.website[each.key].name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
