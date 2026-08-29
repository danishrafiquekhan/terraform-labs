# The deliberate misconfiguration (never applied — shown for documentation only)

This is what `main.tf`'s `azurerm_network_security_group` block looked like
*before* the fix, to document the vulnerable state without ever actually
creating it on a real subscription, even briefly:

```hcl
security_rule {
  name                       = "AllowSSHFromAnywhere"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "0.0.0.0/0"   # <-- the misconfiguration: internet-wide SSH access
  destination_address_prefix = "*"
}
```

## Why this is dangerous
`0.0.0.0/0` on port 22 means any host on the internet can attempt to
authenticate. This is one of the single most common real-world cloud
misconfigurations, and exactly what Microsoft Defender for Cloud's
"Management ports should be closed" recommendation flags automatically —
that's the paid-tier detection equivalent to this exercise (see the main
README's tool comparison table).

## The fix, applied in `main.tf`
Replace `0.0.0.0/0` with a specific known CIDR (`var.allowed_ssh_source_cidr`,
e.g. your own home/office IP as a `/32`) — narrowing the source range from
"the entire internet" to "the one place you actually connect from."

## What I learned / trade-offs
A `/32` source range is safe but brittle — it breaks the moment your IP
changes (common on home broadband). The more robust real-world fix is to
remove direct SSH exposure entirely and go through a bastion host or
Azure Bastion, which never opens port 22 to any public IP at all. Documented
here as the "next step up" rather than implemented, since it needs an extra
resource (`azurerm_bastion_host`) with its own cost.
