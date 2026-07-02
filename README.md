# TerraVault

Terraform for object storage on Azure and Google Cloud. Each environment gets its own root module and state. CI runs `fmt` and `validate` on every push; a nightly job flags drift.

The modules here are thin wrappers. They pin upstream versions, map our variable names, and set defaults. We are not vendoring or copying upstream repos.

| Cloud | Implementation | Notes |
| ----- | -------------- | ----- |
| Azure | Native `azurerm` in `modules/azure_storage` | Inputs follow patterns from [Azure AVM storage](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest) |
| GCP   | [`terraform-google-modules/cloud-storage/google`](https://registry.terraform.io/modules/terraform-google-modules/cloud-storage/google/latest) | `~> 12.3` |

## Layout

```
.
├── modules/
│   ├── azure_storage/          # storage account + lifecycle policy
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── gcs_storage/            # wrapper over Google's cloud-storage module
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
│       ├── azure/              # CMK on
│       └── gcp/                # CMK on
├── backend.tf.example          # remote state snippets for azurerm & gcs
└── .github/workflows/
    ├── terraform-plan.yml      # fmt / validate / init (matrix: env x cloud)
    └── drift-check.yml         # scheduled plan -detailed-exitcode
```

## Environments

Each `environments/<env>/<cloud>` folder is a separate Terraform root. State stays isolated, and you can promote changes dev → staging → prod without sharing backends.

| Environment | Azure | GCP | Notes |
| ----------- | ----- | --- | ----- |
| `dev`       | ✅    | ✅  | CMK optional, short retention |
| `staging`   | ✅    | ✅  | Same shape as prod, for pre-release checks |
| `prod`      | ✅    | ✅  | Customer-managed keys, versioning, longer retention |

## Getting started

1. Copy the backend block you need from [`backend.tf.example`](./backend.tf.example) into `backend.tf` under the target environment, then fill in your state bucket details.
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and set real values. Do not commit `terraform.tfvars`.
3. Log in to your cloud (`az login` or `gcloud auth application-default login`).
4. Run Terraform:

```bash
cd environments/dev/azure
terraform init
terraform plan
terraform apply
```

## CI

**terraform-plan.yml** runs on push and PR. A matrix over `{dev, staging, prod} x {azure, gcp}` runs `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate`. Backend init is off so you do not need cloud creds in CI.

**drift-check.yml** runs on a daily cron. It runs `terraform plan -detailed-exitcode` per environment and fails when drift shows up (exit code `2`).

## Conventions

- Wrappers pin versions and translate variables. Topology choices live in `environments/`.
- Remote state with locking (Azure blob lease / GCS). See `backend.tf.example`.
- Real `*.tfvars` and secrets stay out of git. Only `*.tfvars.example` is committed.
