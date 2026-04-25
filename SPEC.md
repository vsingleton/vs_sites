# sunshinebrass.com OpenTofu Project Spec

## Goal

Host multiple static websites (one per third-level hostname under sunshinebrass.com) on GCS, fronted by a global GCP external Application Load Balancer with HTTPS.

## Architecture

```
Internet → Global Forwarding Rules (80/443)
         → Target HTTP/HTTPS Proxies
         → URL Map  (host_rule per hostname → path_matcher → backend bucket)
         → Compute Backend Buckets (Cloud CDN enabled)
         → GCS Buckets (public, static website)
```

## Key Design Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| LB type | Global external Application LB | Best CDN/GCS integration; regional LBs have limited GCS backend support |
| SSL | Google-managed cert per hostname | Classic managed certs don't support wildcards; one cert per hostname validates via HTTP once A record is set |
| Public access | `allUsers` objectViewer via IAM | Modern uniform bucket-level access; no legacy ACLs |
| CDN | Enabled (`CACHE_ALL_STATIC`) | Free for GCS-backed LBs; reduces latency |
| DNS | Not managed here | sunshinebrass.com is on GoDaddy; user adds A records manually after `tofu apply` |
| TFstate | GCS bucket `sunshinebrass-tfstate` | Same pattern as reference project |

## Variables

| Name | Type | Description |
|------|------|-------------|
| `gcp_project` | string | GCP project ID (`tbj-sites`) |
| `gcp_region` | string | Region for regional resources (`us-central1`) |
| `hostnames` | list(string) | Hostnames to host (set in verns.tfvars) |

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Provider version constraints (google ~> 7.0, tofu >= 1.8) |
| `provider.tf` | Google provider config |
| `backend.tf` | GCS remote state backend |
| `variables.tf` | Input variable declarations |
| `locals.tf` | Shared labels |
| `tfstate-bucket.tf` | `sunshinebrass-tfstate` GCS bucket (versioned) |
| `buckets.tf` | Website GCS buckets + allUsers IAM (for_each over hostnames) |
| `backend-buckets.tf` | Compute backend buckets with CDN (for_each over hostnames) |
| `ssl-certificate.tf` | Google-managed SSL cert per hostname (for_each over local.hostnames) |
| `url-map.tf` | URL map with dynamic host_rule + path_matcher blocks |
| `load-balancer.tf` | Global address, HTTP/HTTPS proxies, forwarding rules |
| `project-services.tf` | Enables required GCP APIs (compute, iam, storage, cloudresourcemanager) |
| `service-account.tf` | Minimal SA for tofu automation (storage.admin, loadBalancerAdmin, networkAdmin) |
| `outputs.tf` | LB IP address (for GoDaddy A records), bucket URLs, SA email |
| `verns.tfvars` | Variable values (gcp_project, gcp_region, hostnames) |

## Project Creation (one-time, before tofu)

```bash
gcloud billing accounts list                        # find your billing account ID
gcloud projects create <project-id> --set-as-default  # creating account becomes Owner
gcloud billing projects link <project-id> \
  --billing-account=XXXXXXX-XXXXXXX-XXXXXXX
```

## Bootstrap Order

The tfstate bucket must exist before the GCS backend can be used:

```bash
# 1. Comment out the backend block in backend.tf
# 2. tofu init && tofu apply -target=google_storage_bucket.tfstate
# 3. Uncomment backend.tf, then:
tofu init   # migrates local state → GCS
tofu apply  # apply everything else
```

## Post-Deploy DNS Steps (GoDaddy)

After `tofu apply`, note the `lb_ip_address` output and add an A record for each
hostname in `var.hostnames` pointing to that IP. Google-managed SSL certs will
provision automatically once DNS resolves (usually within 15–60 minutes).

## Adding a New Hostname

1. Add the hostname string to `hostnames` in `verns.tfvars`
2. `tofu apply` — creates bucket, backend bucket, SSL cert, and URL map entry
3. Add A record in GoDaddy → cert provisions

## Service Account IAM Roles

| Role | Why needed |
|------|-----------|
| `roles/storage.admin` | Create/delete buckets; set allUsers IAM on buckets |
| `roles/compute.loadBalancerAdmin` | Backend buckets, URL maps, proxies, forwarding rules, SSL certs |
| `roles/compute.networkAdmin` | Allocate global IP addresses |
