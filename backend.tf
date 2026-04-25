# Backend values cannot use variables in OpenTofu. Supply them via backend.hcl:
#   tofu init -backend-config=backend.hcl
# The bucket name in backend.hcl must match the google_storage_bucket.tfstate resource.
terraform {
  backend "gcs" {}
}
