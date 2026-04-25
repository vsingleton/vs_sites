variable "gcp_project" {
  type        = string
  description = "GCP project ID"
}

variable "project_name" {
  type        = string
  description = "Short name used to prefix all GCP resource names and the tfstate bucket"
}

variable "gcp_region" {
  type        = string
  description = "GCP region for regional resources"
}

variable "domain" {
  type        = string
  description = "Base domain all subdomains belong to (e.g. example.com)"
}

variable "subdomains" {
  type        = list(string)
  description = "Third-level subdomain labels to host as static websites (e.g. alpha, beta)"
}
