**06 — security header baseline at the gateway**

An `azurerm_application_gateway` with a rewrite rule set that adds the security
headers an external pen test or scanner keeps flagging as missing, and strips the
headers that leak framework/version info. Follows the same BEFORE/AFTER pattern as
exercise 05: `BEFORE.md` documents the gap as it actually looked (a routing rule
with no rewrite rule set at all), `main.tf` only ever contains the fixed version.

**The pattern this is based on**
Multiple web apps sitting behind one Application Gateway, each deployed and
maintained by a different team on its own schedule. An external pen test / scan
report kept coming back with the same findings, missing `Strict-Transport-Security`,
inconsistent `Content-Security-Policy` (present on some apps, absent on others),
no `X-Content-Type-Options`, and version-disclosure headers like
`X-AspNet-Version` and `Server` announcing exactly what framework and version to go
look up known CVEs for. None of that is one team being careless, it's what happens
by default any time header hygiene is left to whoever happens to be deploying an
app that week.

**Why enforce this at the gateway instead of trusting every app deployment**
Because "every app team remembers to configure this correctly, every time, forever"
is not a control, it's a hope. A rewrite rule set on the gateway is one place to
get it right instead of N places to get it right, and it holds even when a new app
gets added behind the gateway by someone who has never read a header hygiene
checklist. This mirrors the same lesson as exercise 05 and exercise 03's networking
module: push the guardrail down to the layer that can't be skipped, instead of
relying on every caller doing the right thing on their own.

**What the rewrite rule set does**
Two rules, applied to every response through the `listener-app-https` listener:
- **`add-security-headers`** (sequence 100) — sets `Content-Security-Policy`
  (from `var.content_security_policy`, since CSP is genuinely app-specific and I'm
  not going to pretend one default fits every app), `Content-Type`,
  `Referrer-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`, and
  `X-Frame-Options`.
- **`strip-version-disclosure-headers`** (sequence 200) — blanks `Server`,
  `X-AspNet-Version`, `X-AspNetMvc-Version`, `X-Powered-By`, `X-XSS-Protection`, and
  `Expect-CT`.

**The honest limitation of this fix**
A rewrite rule can normalize what header *name and value* leaves the gateway. It
cannot verify that the `Content-Security-Policy` value is actually a good policy
for the app behind it, or that the app doesn't have inline `<script>` tags that
break silently the moment a strict CSP gets turned on for real. That's still a
conversation with whoever owns the app, not something Terraform can automate away.
Gateway-level enforcement closes the "somebody forgot to configure this" gap. It
does not close the "the app itself is insecure" gap, those are different problems
and this only solves the first one.

The `Content-Type` header is also worth being honest about: hardcoding
`text/html; charset=UTF-8` at the gateway is fine for a page-serving app, it is the
wrong move for an API that returns JSON. If this pattern gets reused for something
other than a plain website, that rule needs to be scoped or dropped, not copy-pasted
blind.

**Running it**
```bash
cp terraform.tfvars.example terraform.tfvars
# fill in your subscription ID, a real Key Vault secret ID for the TLS cert if
# actually applying this, and a CSP value that matches whatever app sits behind it

az login
terraform init
terraform plan
terraform apply
terraform destroy   # when done
```

**Notes from actually running this**
`terraform fmt` and `terraform validate` pass clean against this config's shape.
Have not applied it against a live subscription, an Application Gateway is not a
free-tier-eligible resource and I did not want to leave one running by accident
just to get a screenshot. The honest next step if I keep going: actually deploy it
in front of a throwaway app, hit it with `curl -I`, and confirm the headers show up
exactly as configured instead of trusting that the HCL is correct.
