# Terraform Labs

**Status: in progress** — one folder per exercise while working through Terraform Associate study material, on an Azure free-tier subscription (never a work/production subscription).

## What this is
Incremental Terraform exercises: a single resource, remote state, modules, and Terraform Cloud integration.

## Why I built it
To build real infrastructure-as-code muscle memory rather than just pass the exam, and to have something concrete to show for the certification.

## How it works
- `01-first-resource-group/` through `04-terraform-cloud-integration/` — each is a standalone exercise with its own README

## What I learned / trade-offs
_(filled in per exercise)_

## Security note
`.tfstate` and `.tfvars` with real values are gitignored from the start (see `.gitignore`). No real subscription IDs, tenant IDs, or credentials are committed — use `<your-subscription-id>` placeholders or environment variables. A pre-commit hook (`.git/hooks/pre-commit`, powered by [gitleaks](https://github.com/gitleaks/gitleaks)) scans staged changes for likely secrets before every commit on this machine.

## Cloud account safety (applies to every exercise here)
- Enable MFA on the Microsoft/Azure account tied to this subscription — same standard as the GitHub account.
- Set a spending alert/budget cap on the subscription before creating any resource (Cost Management + Billing → Budgets).
- Auth is always via `az login` (short-lived token) — never a long-lived client secret or key committed anywhere.
- Run `terraform destroy` when an exercise is done so nothing keeps running (and costing money) unattended.
