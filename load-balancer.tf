resource "google_compute_global_address" "website" {
  name       = "${var.project_name}-lb-ip"
  depends_on = [google_project_service.compute]
}

resource "google_compute_target_http_proxy" "website" {
  name    = "${var.project_name}-http-proxy"
  url_map = google_compute_url_map.website.id
}

resource "google_compute_target_https_proxy" "website" {
  name             = "${var.project_name}-https-proxy"
  url_map          = google_compute_url_map.website.id
  ssl_certificates = [for cert in google_compute_managed_ssl_certificate.website : cert.self_link]
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.project_name}-http"
  target     = google_compute_target_http_proxy.website.self_link
  ip_address = google_compute_global_address.website.address
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.project_name}-https"
  target     = google_compute_target_https_proxy.website.self_link
  ip_address = google_compute_global_address.website.address
  port_range = "443"
}
