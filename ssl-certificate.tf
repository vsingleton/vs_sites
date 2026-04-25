resource "google_compute_managed_ssl_certificate" "website" {
  for_each = toset(local.hostnames)

  name = "${replace(each.key, ".", "-")}-cert"

  managed {
    domains = [each.key]
  }
}
