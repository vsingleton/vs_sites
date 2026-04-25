# vs_sites

OpenTofu project that provisions a global GCP load balancer and per-subdomain GCS static website buckets for a single domain.

## One-time GCP project setup

These commands must be run manually before tofu can manage anything. The account that runs them becomes project Owner.

```bash
# Find your billing account ID
gcloud billing accounts list

# Create the project (run as the account that will own it)
gcloud projects create tbj-sites --set-as-default

# Link billing
gcloud billing projects link tbj-sites --billing-account=XXXXXXX-XXXXXXX-XXXXXXX
```

## Bootstrap

The tfstate bucket must exist before the GCS backend can be used:

```bash
# 1. Ensure backend block in backend.tf is commented out, then:
tofu init
tofu apply -target=google_storage_bucket.tfstate -var-file=verns.tfvars

# 2. Uncomment the backend block in backend.tf, then migrate state:
tofu init -backend-config=backend.hcl

# 3. Apply everything else:
tofu apply -var-file=verns.tfvars
```

## Day-to-day usage

```bash
tofu plan -var-file=verns.tfvars
tofu apply -var-file=verns.tfvars
```

## Adding a subdomain

1. Add the label to `subdomains` in `verns.tfvars`
2. `tofu apply -var-file=verns.tfvars`
3. Add an A record in GoDaddy pointing to `lb_ip_address` output
