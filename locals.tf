locals {
  labels = {
    creator = "${var.project_name}-tofu"
  }

  hostnames = [for s in var.subdomains : "${s}.${var.domain}"]
}
