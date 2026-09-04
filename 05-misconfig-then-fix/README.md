**05 — misconfig, then fix it**

An NSG with SSH locked down to a specific IP range instead of the internet. Built so the *vulnerable* version only ever exists as documentation, never as something actually deployed.

**Why I built it this way**
The original idea (from a test-case list I was working through) was: deploy something with a real misconfig, catch it with Defender for Cloud, screenshot the finding, fix it. Defender for Cloud isn't in the Azure free tier though, and I wasn't willing to actually open port 22 to the entire internet on a real subscription just to get a screenshot — even briefly, even on a throwaway lab account. So `BEFORE.md` documents exactly what the vulnerable block looked like and why it matters, and `main.tf` only ever contains the fixed version.

**What I used instead of Defender for Cloud**
Just manual review, written up properly instead of a tool doing it for me. If I ever do turn on Defender for Cloud's free tier on this subscription, applying the `BEFORE.md` version for the few seconds it'd take to get a real finding screenshot would upgrade this from "documented" to "actually demonstrated" — I know that's the stronger version of this exercise, just didn't think it was worth the exposure to get there.

**Running it (fixed version only)**
```bash
cp terraform.tfvars.example terraform.tfvars
# fill in your subscription ID and your own IP/32 for allowed_ssh_source_cidr
terraform init
terraform plan
terraform apply
terraform destroy   # when done
```

**What I'd change if I kept going**
The `/32` fix works but it's brittle — breaks the moment your home IP changes, which happens more than you'd think on residential broadband. The actual robust answer is removing direct SSH exposure entirely and going through Azure Bastion instead, which never opens port 22 to any public IP at all. Didn't build that here since it's an extra resource with its own ongoing cost, but it's the right next step, not a hypothetical.
