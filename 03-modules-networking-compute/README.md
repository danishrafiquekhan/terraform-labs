**03 — modules: networking + compute**

Everything up to this point has been one flat `main.tf`. That's fine for a single resource group or one NSG, it stops being fine the moment you want the same networking pattern in more than one place. This exercise splits that pattern into two reusable modules and calls them from a root config, which is the module composition pattern the Associate exam expects you to recognize.

**Layout**
```
03-modules-networking-compute/
├── main.tf              # root config: resource group + both module calls
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
└── modules/
    ├── networking/       # vnet, subnet, NSG, subnet-NSG association
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── compute/          # NIC + Linux VM
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Why split it this way**
Networking and compute change for different reasons and on different timelines. I might want to reshape the subnet layout without touching the VM, or swap VM sizes without touching the vnet at all. Two modules with a narrow interface between them (the root passes `module.networking.subnet_id` into the compute module) makes that possible. It also mirrors the layer boundary I'd actually draw in a real environment: network team owns one, whoever owns the workload owns the other.

**What each module does and does not decide**
The **networking module** hardcodes the security posture, not just the shape. It only exposes an `allowed_ssh_source_cidr` variable, there's no variable that lets a caller open port 22 to `0.0.0.0/0` even by accident, the module simply doesn't have that knob. Same lesson as exercise 05, just enforced one level up instead of trusted to whoever calls it.

The **compute module** sets `disable_password_authentication = true` explicitly and only accepts an SSH public key, never a password variable. There is no path through this module that creates a VM you can password-guess into.

**Module inputs and outputs, briefly**
- `networking` takes a resource group, location, name prefix, address ranges (with sane defaults), and the allowed SSH CIDR. It outputs `vnet_id`, `subnet_id`, and `nsg_id`.
- `compute` takes a resource group, location, name prefix, the `subnet_id` from the networking module's output, a VM size (defaults to `Standard_B1s`, a free-tier-eligible burstable size), and an SSH public key. It outputs the VM's `vm_id` and `private_ip_address`.

The root `main.tf` is the only place these two modules are wired together. Neither module references the other directly, they only communicate through values the root passes between them, which is what keeps them independently reusable.

**Running it**
```bash
cp terraform.tfvars.example terraform.tfvars
# fill in subscription ID, your own IP/32, and your SSH public key contents

az login
terraform init
terraform plan
terraform apply
```

**Cleaning up**
```bash
terraform destroy
```

**Notes from actually running this**
`terraform init` (which also initializes both local modules), `terraform validate`, and `terraform fmt -check` all pass clean. Have not yet run `apply` against a live subscription, this exercise is currently validated at the "config is structurally correct and modules compose the way I intended" level, not the "confirmed it deploys" level. Next honest step if I keep going: actually apply it, SSH into the VM using the key instead of a password, and confirm the NSG rule is doing what I think it's doing from an IP outside the allowed range.
