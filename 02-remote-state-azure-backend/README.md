# 02 — remote state, azurerm backend

Exercise 01 used local state (`terraform.tfstate` sitting on my laptop, gitignored). That is fine for a single person clicking apply once, and it is exactly why it does not scale past that. This exercise moves state into an Azure Storage blob instead, which is the standard answer for azurerm-backed Terraform and one of the more heavily tested topics on the Associate exam.

## Why remote state actually matters
Local state has three real problems, not just theoretical ones:
- **No locking between people.** Two applies running against the same local file at the same time corrupt it. There is no coordination mechanism at all.
- **No shared source of truth.** If state lives on my laptop, nobody else (and no CI pipeline) can plan or apply against the same infrastructure without copying the file around by hand, which is its own security problem.
- **No durability.** A local `.tfstate` file is one `rm -rf` or one dead disk away from being gone, along with the only record Terraform has of what it actually created.

The azurerm backend fixes all three: state lives in a blob, state locking is handled automatically through a blob lease (no separate DynamoDB-style table needed like the AWS S3 backend requires), and the blob has normal Azure durability and access control on it.

## The chicken-and-egg problem
The backend for a Terraform config has to exist before that config can use it. But the backend here is itself an Azure storage account, and Terraform cannot create the very backend it is about to store its state in. This is a documented limitation, not something I got stuck on.

The way this is handled: the backend storage account is bootstrapped once, by hand, with the Azure CLI, completely outside of this Terraform config. It is not managed by any `.tf` file in this repo. That is a deliberate boundary, not an oversight.

```bash
# One-time bootstrap, run once, outside of Terraform
az group create --name rg-tfstate-bootstrap --location westeurope

az storage account create \
  --name <your-globally-unique-storage-account-name> \
  --resource-group rg-tfstate-bootstrap \
  --sku Standard_LRS \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

az storage container create \
  --name tfstate \
  --account-name <your-globally-unique-storage-account-name> \
  --auth-mode login
```

`--allow-blob-public-access false` matters here. State files can contain sensitive values (connection strings, sometimes secrets depending on the resource), so the container backing them should never be reachable anonymously.

## Wiring the config to that backend
`providers.tf` has a deliberately empty `backend "azurerm" {}` block. The actual resource group, storage account, container, and state file key come from `backend.hcl`, which is gitignored the same way `terraform.tfvars` is (see `backend.hcl.example` for the shape of it, and the repo `.gitignore`). This is Terraform's "partial configuration" pattern, and it exists specifically so backend details do not have to be hardcoded into version-controlled files.

```bash
cp backend.hcl.example backend.hcl
# fill in the resource group / storage account you bootstrapped above

cp terraform.tfvars.example terraform.tfvars
# fill in your subscription ID

az login
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Cleaning up
```bash
terraform destroy
```

This tears down the resource group and storage account this exercise's `main.tf` created. It does **not** touch the bootstrap resource group or backend storage account, those were created outside Terraform and stay around on purpose, they hold state for every future exercise that reuses this backend. Delete `rg-tfstate-bootstrap` by hand with `az group delete` only when I am completely done with this whole repo, not after a single exercise.

## Notes from actually running this
`terraform init` and `terraform validate` both pass clean against the backend/partial-configuration pattern above. Have not yet run `apply` against a live subscription. The honest gap here is I have not tested what a genuine concurrent-apply lock conflict looks like in practice, running two `apply`s at once on purpose to see the "state is locked" error message from the blob lease. That is a reasonable next step if I want the strongest possible version of this exercise, just have not done it yet.
