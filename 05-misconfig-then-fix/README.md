# 05 — Misconfig, Then Fix It

**Status: ready to run**, and deliberately built so the vulnerable state is *documented*, not *deployed*.

## What this is
A Terraform-managed Network Security Group demonstrating a real, extremely common cloud misconfiguration (SSH open to `0.0.0.0/0`) and its fix — but see `BEFORE.md` for why the vulnerable version was never actually applied to a real subscription.

## Why I built it
Catalog test case 5.1 calls for "deploy with an intentional misconfig, then detect and fix it, with a Defender for Cloud finding screenshot." Defender for Cloud isn't in the Azure free tier, so this documents the same finding a paid tool would generate, without paying for it — see the comparison table below.

## How it works
- `main.tf` — the **fixed** state: SSH restricted to a specific CIDR you control
- `BEFORE.md` — the misconfigured state this replaced, and why it's dangerous, shown as documentation rather than ever actually created

## Ideal tool vs. what I used
| | Ideal (catalog spec) | What I actually used |
|---|---|---|
| Detection | Microsoft Defender for Cloud ("management ports open" recommendation) | Manual code review + documentation (Defender for Cloud's free tier covers this specific check, but I didn't have a subscription with it enabled at build time) |
| Evidence | Screenshot of the Defender for Cloud finding | Written before/after comparison in `BEFORE.md` |

If you do enable Defender for Cloud's free tier on your lab subscription later, applying the `BEFORE.md` version briefly and capturing the real finding screenshot would upgrade this from "documented" to "demonstrated" — noted as a next step, not done here on purpose (didn't want to actually expose port 22 to the internet, even briefly, just to get a screenshot).

## Run it (the safe, fixed version only)
```bash
cp terraform.tfvars.example terraform.tfvars
# edit: your subscription ID, and your own IP/32 for allowed_ssh_source_cidr
terraform init
terraform plan
terraform apply
terraform destroy   # when done
```

## What I learned / trade-offs
See `BEFORE.md` — the `/32` fix is safe but brittle against changing home IPs; Azure Bastion is the more robust real answer, not implemented here due to its own extra cost.
