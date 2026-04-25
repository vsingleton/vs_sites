resource "google_compute_backend_bucket" "website" {
  for_each = toset(local.hostnames)

  name        = "${replace(each.key, ".", "-")}-backend"
  bucket_name = google_storage_bucket.website[each.key].name
  enable_cdn  = true

  cdn_policy {
    cache_mode = "CACHE_ALL_STATIC"
    default_ttl = 180
    max_ttl     = 180
    client_ttl  = 180
    negative_caching = true
    negative_caching_policy {
      code = 404
      ttl  = 30
    }
  }
}
