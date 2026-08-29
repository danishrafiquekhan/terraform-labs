# 01 — First Resource Group

**Status: ready to run** — this is a working Terraform config, not a template. It just needs your own free-tier Azure subscription ID.

## What this is
The smallest possible Terraform exercise: authenticate to Azure, declare one resource group, apply it, destroy it.

## Before you run this
1. **Use a free-tier subscription, never a work/production one.** Create one at https://azure.microsoft.com/free if you don't have one.
2. **Set a spending alert/budget cap** in the Azure portal on that subscription immediately (Cost Management + Billing → Budgets) — do this before creating any resource, not after.
3. Log in with the Azure CLI (already installed): `az login` — this opens a browser, authenticates you, and stores a short-lived token locally. No password or key is ever written into this repo.
4. Copy the example vars file and fill in your own subscription ID: `cp terraform.tfvars.example terraform.tfvars` (this file is gitignored — it will never be committed).

## How to run it
```bash
az login
az account list --output table          # confirm you're on the lab subscription, not a work one
terraform init
terraform plan
terraform apply
```

## Clean up (do this when done, so nothing keeps costing money)
```bash
terraform destroy
```

## What I learned / trade-offs
_(fill in after running it — e.g. what `az login` device flow looked like, what the plan output showed before apply)_

## Security note
`terraform.tfvars` and `.tfstate` are gitignored at the repo root — they can contain real subscription IDs and resource state. Never remove those `.gitignore` entries.
