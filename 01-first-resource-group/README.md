# 01 — first resource group

The smallest possible thing: log into Azure, declare one resource group, apply it, tear it down. This is a real working config, not a template — just needs your own subscription ID.

## Before running it
1. Use a free-tier subscription, not a work one. Sign up at azure.microsoft.com/free if you need one.
2. Set a spending cap in the portal (Cost Management → Budgets) before creating anything.
3. `az login` — opens a browser, authenticates, stores a short-lived token. Nothing gets written into this repo from that.
4. `cp terraform.tfvars.example terraform.tfvars` and fill in your subscription ID. That file's gitignored, it never gets committed.

## Running it
```bash
az login
az account list --output table    # double check you're on the lab subscription
terraform init
terraform plan
terraform apply
```

## Cleaning up
```bash
terraform destroy
```

## Notes from actually running this
`terraform init` and `terraform validate` both pass clean — confirmed the provider config and resource block are syntactically correct. Haven't actually run `apply` against a real subscription yet since I don't have one set up right now; that's the honest next step, not something I'm claiming is done.

`.tfvars` and `.tfstate` are gitignored at the repo root — don't touch those entries even if it seems convenient in the moment.
