# 07 — WAF + APIM pilot (detection mode)

A second listener on the same Application Gateway from exercise 06's pattern, this
time routed to an API Management dev instance instead of a website, sitting behind
a WAF policy that is deliberately in **Detection** mode, not Prevention. No
BEFORE/AFTER split this time, there's no misconfiguration being fixed here, it's a
pilot, so a single walkthrough README fits better than the 05/06 pattern.

## The pattern this is based on
The longer-term goal is making APIM private (no public inbound endpoint at all) and
routing every request to it through the Application Gateway, which already has a
WAF in front of the website traffic. Before flipping that switch for real API
traffic, the plan is to add a new listener on the existing gateway pointed at the
APIM **dev** instance, run the same WAF ruleset the website listener already runs
in **Detection** mode, and watch what it flags for a while before deciding which
rules are safe to actually enforce.

## Why Detection mode, not Prevention, on day one
Because an untuned WAF ruleset in Prevention mode in front of API traffic is a
great way to start silently blocking legitimate requests you don't find out about
until someone's integration breaks. Website traffic and API traffic don't look the
same to a generic ruleset, things like large JSON bodies, unusual-looking but
completely legitimate query parameters, or auth headers with base64 payloads can
trip rules tuned against form-post and query-string patterns from web traffic. In
Detection mode, the WAF logs what it *would* have blocked without actually blocking
it, which turns "the ruleset might have false positives" from a guess into
something I can actually go look at.

## What I'd watch for before flipping to Prevention
- The WAF policy's diagnostic logs, specifically which rule IDs are firing against
  real dev traffic and how often, not just whether *any* rule fired.
- Whether the same rule IDs fire repeatedly against traffic I can independently
  confirm is legitimate (a known API consumer's normal request pattern), versus
  fires that only ever show up alongside traffic that actually looks like scanning
  or abuse.
- Enough time and traffic volume for the sample to mean something. A day of quiet
  dev traffic proves a lot less than a week that includes a normal release cycle
  with real client integrations hitting it.
- A documented decision, rule by rule, for anything getting explicitly disabled or
  overridden, not a blanket "just don't block anything" exclusion that defeats the
  point of having a WAF at all.

## What's in this config
- `azurerm_web_application_firewall_policy.pilot` — OWASP 3.2 managed rule set,
  `mode = "Detection"`, same ruleset the website listener would run under so this
  pilot is actually representative of what Prevention mode would later enforce.
- The existing website listener (`listener-website-https`, `backend-pool-website`)
  — included as a placeholder standing in for what's already live on the real
  gateway, so the new listener reads as an addition, not a gateway built from
  scratch just for this experiment.
- The new pilot pieces: `listener-apim-dev-https` (host-based/SNI listener bound to
  `var.apim_dev_hostname`, a fictional dev hostname), `backend-pool-apim-dev`
  (pointed at a placeholder APIM dev gateway FQDN), a health probe against APIM's
  built-in `/status-0123456789abcdef` endpoint, and the routing rule tying it
  together. Both listeners share the same frontend IP/port and are distinguished by
  SNI hostname, and both sit behind the one WAF policy defined above.

## What this lab does not cover
Just the pilot listener and the WAF policy sitting in front of it. It does not
cover making the actual APIM instance private, removing its public endpoint,
setting up a private endpoint or VNet integration for it, or migrating all inbound
API traffic through the gateway exclusively, that's the real end state this is a
step toward, and it's a bigger, riskier change with its own separate rollout plan.
Doing that without observing this pilot first would be skipping the exact step
this exercise exists to demonstrate.

## Running it
```bash
cp terraform.tfvars.example terraform.tfvars
# fill in your subscription ID and real values if actually applying this

az login
terraform init
terraform plan
terraform apply
terraform destroy   # when done
```

## Notes from actually running this
`terraform fmt` and `terraform validate` pass clean against this config's shape.
Have not applied it against a live subscription — WAF_v2 tier Application Gateway
capacity is a real ongoing cost and I don't have an APIM dev instance sitting
around in this lab subscription to point it at. The honest next step if I kept
going: stand up an actual APIM dev instance, apply this for real, generate some
representative API traffic against it, and pull the WAF diagnostic logs to see
what Detection mode actually flags instead of only reasoning about what it might.
