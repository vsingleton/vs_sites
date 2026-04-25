resource "google_compute_url_map" "website" {
  name            = "${var.project_name}-url-map"
  default_service = google_compute_backend_bucket.website[local.hostnames[0]].self_link

  dynamic "host_rule" {
    for_each = toset(local.hostnames)
    content {
      hosts        = [host_rule.value]
      path_matcher = replace(host_rule.value, ".", "-")
    }
  }

  dynamic "path_matcher" {
    for_each = toset(local.hostnames)
    content {
      name            = replace(path_matcher.value, ".", "-")
      default_service = google_compute_backend_bucket.website[path_matcher.value].self_link
    }
  }

  depends_on = [google_compute_backend_bucket.website]
}
