**What this looked like before the fix**

Never actually applied anywhere — this is what the `azurerm_network_security_group` block in `main.tf` would've looked like if I'd built the vulnerable version instead of jumping straight to the fix:

```hcl
security_rule {
  name                       = "AllowSSHFromAnywhere"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "0.0.0.0/0"   # the actual problem
  destination_address_prefix = "*"
}
```

**Why this matters**
`0.0.0.0/0` on port 22 means literally any host on the internet can attempt to authenticate against it. It's one of the most common cloud misconfigurations there is, and it's exactly what Microsoft Defender for Cloud's "management ports should be closed" check flags automatically — the paid-tool version of the review I did by hand here.

**What changed**
Swapped `0.0.0.0/0` for a specific CIDR (`var.allowed_ssh_source_cidr`) — your own IP as a `/32`, instead of the whole internet.

**The honest limitation of the fix**
A `/32` is safe but fragile — it breaks the second your home IP changes, which happens more often than people expect on residential connections. The better long-term answer is to not expose SSH directly at all and put a bastion host (Azure Bastion) in front of it instead. Didn't build that here, mostly because it's an extra always-on resource with its own cost, but it's the right answer if this were a real environment instead of a lab.
