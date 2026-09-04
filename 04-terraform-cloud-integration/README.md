**04 — Terraform Cloud (HCP Terraform) integration**

HashiCorp renamed Terraform Cloud to HCP Terraform a while back, the product and the free tier are the same thing, the exam material (and most job postings) still say "Terraform Cloud" so that's what I'm calling this folder. This exercise swaps the azurerm blob backend from exercise 02 for HCP Terraform as both the state backend and the place `plan`/`apply` actually execute.

**What's different from exercise 02**
Exercise 02's backend only stores state, the actual `terraform apply` still runs on my laptop using my own `az login` session. This exercise moves execution itself off my machine. `terraform plan` and `terraform apply` run on HCP Terraform's own remote workers, my laptop just streams the logs. That has real consequences: my local `az login` token is worthless to a run that doesn't happen on my local machine, so authentication has to come from somewhere the remote worker can actually read.

**Setting up the workspace (one-time, in the HCP Terraform UI)**
1. Create a free HCP Terraform account, separate from the Azure account, at app.terraform.io.
2. Create an organization (placeholder `<your-hcp-terraform-org>` in `providers.tf`, fill in the real one only in your own untracked checkout, never commit it).
3. Create a workspace named `terraform-labs-04` (or whatever you set in the `cloud` block), using the **CLI-driven** workflow, not the VCS-connected one. VCS-connected would mean HCP Terraform triggers a real `apply` on every push to this repo, and I don't want infrastructure changes firing off just because I pushed a README typo fix.
4. Set execution mode to **Remote** (the default) so `apply` actually runs on HCP Terraform's workers, not just stores state for a local apply.

**Auth: no `az login` on a remote worker**
Every other exercise in this repo authenticates through `az login`, a short-lived token tied to my local session. That doesn't exist on a remote HCP Terraform worker. The answer here is an Azure service principal, created once via the CLI and never touched by hand again:

```bash
az ad sp create-for-rbac \
  --name "sp-terraform-labs-04" \
  --role Contributor \
  --scopes /subscriptions/<your-subscription-id>
```

That prints an `appId`, `password`, and `tenant`. Those become **workspace variables** in HCP Terraform, not anything written to this repo:
- `ARM_CLIENT_ID` = appId
- `ARM_CLIENT_SECRET` = password, marked **sensitive** in the HCP Terraform UI so it's write-only after saving
- `ARM_TENANT_ID` = tenant
- `ARM_SUBSCRIPTION_ID` = subscription ID

All four as Terraform environment variables (not "Terraform variables", the distinction matters in the UI), since the azurerm provider reads them from the environment when they're not passed explicitly.

**Variable sets vs. terraform.tfvars**
This is the actual conceptual shift from every other exercise here. `terraform.tfvars` is a file on disk, local backend and local execution read it automatically, that's how exercises 01, 02, 03, and 05 all get their subscription ID. HCP Terraform doesn't read `terraform.tfvars` at all, because the run doesn't happen on a machine that has that file, it happens on a remote worker that only ever sees what's committed to the repo plus whatever the workspace itself provides.

HCP Terraform's answer is **workspace variables**, and one level up from that, **variable sets**: a named bundle of variables (the four `ARM_*` ones above, for instance) that can be attached to more than one workspace at once. If I add a `05` or `06` HCP-Terraform-backed exercise later, that same service principal's credentials get reused via one variable set attached to both workspaces, instead of re-entering four secrets by hand per workspace. `terraform.tfvars.example` in this folder is really just documentation of what a variable set here maps to, and a convenience if I ever want to `plan` locally against a non-cloud backend override for quick syntax checking; the real values never live in a file in this repo either way.

**Running it**
```bash
terraform login    # opens a browser, stores an HCP Terraform API token in your local CLI config, not in this repo
terraform init
terraform plan      # streams from the remote run, doesn't execute locally
terraform apply
```

**Cleaning up**
```bash
terraform destroy
```
Also runs remotely. And if I'm fully done with this exercise, the service principal created above should get deleted too (`az ad sp delete --id <appId>`), not just the resource group, credentials sitting around unused are their own risk.

**Notes from actually running this**
`terraform init` and `terraform validate` pass clean for the `cloud` block syntax and provider config. Have not created the actual HCP Terraform organization/workspace yet, so this is validated at the "config is correct HCL and the cloud block is wired the way the docs describe" level, not "confirmed a real remote run executed" level. That's the honest next step before I'd call this one fully demonstrated rather than just built.
