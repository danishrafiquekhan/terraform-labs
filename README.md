# terraform-labs

Working through the Terraform Associate material one exercise per folder. Doing this because I want actual muscle memory with it, not just enough to pass a multiple-choice exam. A lot of the detection/security automation roles I am looking at expect you to be comfortable deploying infrastructure as code, not just reading someone else's Terraform.

Everything here runs against a free-tier Azure subscription that is completely separate from any work tenant. Never pointing this at anything real.

`.tfstate` and any `.tfvars` with actual values are gitignored from the start, not something I added after a scare, just built in from the first commit. No real subscription IDs or credentials ever get committed; placeholders and environment variables only. There is also a gitleaks hook (see setup below) as a second layer, though I have already found it does not catch everything. A password string with a `$` in it slipped past it once during testing, so I do not treat "the hook did not complain" as proof of anything.

## Before touching any of this
- MFA on the Microsoft account tied to the subscription
- A spending cap set in Cost Management before creating anything, not after
- Auth always through `az login`, never a long-lived secret sitting in a file
- `terraform destroy` when I am done with an exercise, so nothing keeps running unattended

## One-time setup after cloning
```bash
git config core.hooksPath .githooks
```
