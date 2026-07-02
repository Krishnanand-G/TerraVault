# TerraVault

Infrastructure-as-Code data platform for provisioning object storage across **Azure** and **Google Cloud**, with multi-environment promotion, CI-driven `plan` gating, and scheduled drift detection.

TerraVault ships **thin wrapper modules** around battle-tested upstream modules rather than reinventing them:

| Cloud | Upstream module | Version |
| ----- | --------------- | ------- |
| Azure | [`Azure/avm-res-storage-storageaccount/azurerm`](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest) (Azure Verified Module) | `~> 0.7` |
| GCP   | [`terraform-google-modules/cloud-storage/google`](https://registry.terraform.io/modules/terraform-google-modules/cloud-storage/google/latest) | `~> 12.3` |

Our modules expose a small, opinionated surface (versioning, lifecycle rules, customer-managed encryption keys) and delegate the heavy lifting to the upstream modules. We do **not** vendor or copy the upstream repositories.

## Repository layout

```
.
├── modules/
│   ├── azure_storage/          # thin wrapper over the Azure AVM storage account module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── gcs_storage/            # thin wrapper over the Google cloud-storage module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── environments/
│   ├── dev/
│   │   ├── azure/
│   │   └── gcp/
│   ├── staging/
│   │   ├── azure/
│   │   └── gcp/
│   └── prod/
│       ├── azure/              # CMK enforced
│       └── gcp/                # CMK enforced
├── backend.tf.example          # remote state + locking snippets for azurerm & gcs
└── .github/workflows/
    ├── terraform-plan.yml      # fmt / validate / init (matrix: env x cloud)
    └── drift-check.yml         # scheduled `plan -detailed-exitcode`
```

## Environments

Each environment/cloud pair is an independent Terraform root module. This isolates state, permits per-environment providers/backends, and lets changes be promoted `dev → staging → prod`.

| Environment | Azure | GCP | Notes |
| ----------- | ----- | --- | ----- |
| `dev`       | ✅    | ✅  | Relaxed: CMK optional, short retention. |
| `staging`   | ✅    | ✅  | Mirrors prod topology for pre-release validation. |
| `prod`      | ✅    | ✅  | **Customer-managed keys enabled**, versioning on, longer retention. |

## Getting started

1. Copy the backend snippet you need from [`backend.tf.example`](./backend.tf.example) into a `backend.tf` in the target environment directory, and fill in your state storage details.
2. Copy the matching `terraform.tfvars.example` to `terraform.tfvars` and fill in real values (never commit `terraform.tfvars`).
3. Authenticate to your cloud (`az login` / `gcloud auth application-default login`).
4. Run Terraform:

```bash
cd environments/dev/azure
terraform init
terraform plan
terraform apply
```

## CI / CD

- **`terraform-plan.yml`** — runs on every push/PR. A matrix across `{dev, staging, prod} x {azure, gcp}` runs `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate`. Backend init is disabled so validation needs no cloud credentials.
- **`drift-check.yml`** — runs on a schedule (daily cron). Executes `terraform plan -detailed-exitcode` against each environment and fails the job when drift is detected (exit code `2`).

## Conventions

- Modules are **thin wrappers**: they pin the upstream version, translate our variable names, and set safe defaults. Business/topology decisions live in the `environments/` roots.
- State is remote and locked (Azure blob lease locking / GCS + native locking). See `backend.tf.example`.
- Secrets and real `*.tfvars` are git-ignored. Only `*.tfvars.example` files are committed.
