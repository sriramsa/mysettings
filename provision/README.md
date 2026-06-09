# Recreate devbox from scratch (disaster recovery)

If the VM is lost, this rebuilds the whole thing: the Azure resources **and** the
dev environment, in two automated layers.

- **Terraform** (`*.tf`) provisions the Azure side: resource group, VNET/subnet,
  NSG (SSH), a **static Standard public IP with your DNS label**, the VM (B4ms /
  Ubuntu 22.04 gen2 / StandardSSD), a **system-assigned identity** that can
  deallocate the VM (scoped role), and the **nightly auto-shutdown + email warning**.
- **cloud-init** (`cloud-init.yaml.tftpl`) runs `bootstrap-devbox.sh` on first
  boot: installs tooling (zsh+oh-my-zsh+p10k, neovim, fzf/ripgrep/bat, node,
  build-essential, claude CLI), clones this repo, and symlinks the dotfiles +
  `devbox`.

The result is the same box you had — minus your *other* project working trees,
which you restore from their own git remotes.

## Prerequisites

- **Terraform** (>= 1.3)
- **Azure CLI**, logged in (`az login`) — the AzureRM provider uses that auth
- Your **SSH public key** (e.g. `~/.ssh/id_ed25519.pub`)

## Run it

```sh
cd provision
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars            # fill in sub id, RG, vm name, dns label, key path, email, repo url

terraform init
terraform plan        # review what will be created
terraform apply       # type 'yes'
```

When it finishes, Terraform prints outputs:

```
fqdn  = "<your-label>.<region>.cloudapp.azure.com"   # <- use this as DEVBOX_SSH
ssh   = "ssh <user>@<fqdn>"
```

cloud-init then runs the OS bootstrap in the background (~5–10 min). Watch it:

```sh
ssh <user>@<fqdn> 'tail -f /var/log/devbox-bootstrap.log'
```

## After it's up

1. `ssh` in, run **`claude`** once and log in (your MAX subscription — this step
   is interactive, so it can't be automated).
2. From your **Mac**, point `DEVBOX_SSH` in `~/.config/devbox.env` at the new
   `fqdn` (it'll be the same if you reused the DNS label). `devbox` works immediately.
3. Re-clone your other projects into `~/src` from their remotes.

## Important: state & secrets

- `terraform.tfstate` and `terraform.tfvars` contain identifiers and are
  **gitignored** — never commit them. For multi-machine recovery, consider a
  remote backend (e.g. an Azure Storage backend) instead of local state.
- Nothing identifying is committed: the `.tf` files are generic; real values
  live only in your local `terraform.tfvars`.

## Notes

- SSH defaults to open (`*`) to match the original. Set `ssh_source_address` to
  your IP/CIDR in tfvars to lock it down.
- Reusing the same `dns_label` keeps your `DEVBOX_SSH` host name stable across a
  rebuild (the label must be unique within the region).
