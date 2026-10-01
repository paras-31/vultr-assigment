# Cloud Native Platform

Production-oriented 2-tier application on Vultr Kubernetes Engine.

This repository is being built in phases. **Phase 0 (Terraform infrastructure) is in place.** Cluster bootstrap, applications, and CI/CD come next after this stack is applied and validated.

## Live URLs (placeholders)

- Frontend: https://app.example.com
- API: https://app.example.com/api
- Health: https://app.example.com/api/health/ready
- Grafana: https://grafana.example.com

## Phase 0 scope

| Stage | Directory | Creates | State |
| --- | --- | --- | --- |
| Bootstrap | `terraform/bootstrap` | Vultr Object Storage + state bucket | Local (on purpose) |
| Infrastructure | `terraform/infrastructure` | VKE 1.36.x cluster + private container registry | Remote S3-compatible backend |

Bootstrap is separate so the state bucket exists before the cluster stack tries to use it. That avoids a circular dependency.

## Prerequisites

- Terraform >= 1.8
- A Vultr account with permission to create Object Storage, VKE, and Container Registry
- `VULTR_API_KEY` exported in your shell (never committed)
- Optional: `vultr-cli` and `curl` to list regions, storage tiers, and Kubernetes versions

## Quick start (Phase 0)

1. Copy example variable files:

```bash
cp terraform/bootstrap/terraform.tfvars.example terraform/bootstrap/terraform.tfvars
cp terraform/infrastructure/terraform.tfvars.example terraform/infrastructure/terraform.tfvars
```

2. Confirm Kubernetes 1.36 is available:

```bash
curl -s https://api.vultr.com/v2/kubernetes/versions \
  -H "Authorization: Bearer $VULTR_API_KEY"
```

Set `kubernetes_version` in `terraform/infrastructure/terraform.tfvars` to an exact `v1.36.x+n` string from that list.

3. Apply bootstrap, then infrastructure. Full commands are in the Phase 0 validation section of the working notes from this assignment, and in the Makefile (`make terraform-fmt`, `make terraform-validate`).

Do not apply the infrastructure stack until bootstrap has succeeded and `backend.hcl` is filled from bootstrap outputs.

## Security

- No API keys, registry passwords, or kubeconfig files are committed.
- Sensitive Terraform outputs are marked `sensitive`.
- `kubeconfig`, `terraform.tfvars`, `backend.hcl`, and state files are gitignored.

## What comes next

Phase 1 will bootstrap Istio Ambient, Gateway API, databases, monitoring, and Infisical on the cluster created here. Do not start Phase 1 until `kubectl get nodes` shows three Ready workers on Kubernetes 1.36.x.
