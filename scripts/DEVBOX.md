# devbox — Azure dev VM + Claude workflow

One portable script (`scripts/devbox`) to start/stop your Azure dev VM, keep
compute bills near zero, and bring up a Claude session you can drive from your
phone. It runs on **both** your Mac and the VM and auto-detects which.

## Commands

| Command | What it does | Runs on |
| --- | --- | --- |
| `devbox up` / `start` | Power on the VM | Mac |
| `devbox down` | **Deallocate** the VM — actually stops compute billing | Mac or VM |
| `devbox status` | Power state + "are you being charged?" | Mac |
| `devbox code [project]` | Start VM → wait for SSH → ensure a remote-controllable Claude tmux session → open VS Code Remote into the project | Mac |
| `devbox claude` | Ensure + attach the Claude tmux session | VM |
| `devbox ssh` | SSH into the VM | Mac |
| `devbox autoshutdown` | Show the Azure auto-shutdown schedule | Mac |
| `devbox help` | Usage | both |

> **Billing note:** `down` always runs `az vm deallocate`, never an OS
> shutdown. An OS shutdown leaves the VM *Stopped (allocated)* and **keeps
> charging** for compute. `devbox status` will warn you if it's in that state.

## How it knows where it is

On startup it asks the Azure Instance Metadata Service (only reachable from
*on* the VM). If it answers → "VM" mode (resource group / name / subscription
come straight from IMDS, no config needed). If not → "Mac" mode, and it reads
your config file.

## Setup

### 1. On the VM (already done if you cloned into `~/src`)

```sh
ln -sf ~/src/mysettings/scripts/devbox ~/.local/bin/devbox   # ~/.local/bin is on PATH
```

No config file needed on the VM.

### 2. On the Mac

```sh
git clone <your-fork-of-mysettings> ~/src/mysettings
ln -sf ~/src/mysettings/scripts/devbox ~/.local/bin/devbox    # or anywhere on PATH

cp ~/src/mysettings/scripts/devbox.env.example ~/.config/devbox.env
$EDITOR ~/.config/devbox.env        # fill in RG, VM, SSH host alias, remote home
```

`DEVBOX_SSH` must match the SSH host alias VS Code uses (the one in your
`~/.ssh/config`). Prefer a **DNS name** over a pinned IP — a deallocated VM with
a dynamic public IP gets a new address on restart, but the DNS alias follows it.

Requirements on the Mac: Azure CLI (`az login` done), the `ssh` client, and
VS Code's `code` command on PATH (VS Code → *Shell Command: Install 'code' in PATH*).

### 3. One-time: let the VM stop itself

So `devbox down` works from *on* the VM, give it a managed identity scoped to
just itself. Run on the **Mac**:

```sh
~/src/mysettings/scripts/devbox-bootstrap-identity.sh
```

This assigns a system-assigned identity and grants it *Virtual Machine
Contributor* on the VM resource only. Role propagation can take ~a minute.

## Daily flow

```sh
# at your desk
devbox code            # starts the VM, brings up Claude (paired to your phone), opens VS Code
# ... work; step away and keep replying to Claude from the phone ...
devbox down            # truly done -> deallocate (from Mac, the VM, or the Azure mobile app)
```

The Azure **auto-shutdown schedule** is your backstop for nights you forget;
check it with `devbox autoshutdown`.

## Mobile

`devbox code` launches Claude inside a **detached** tmux session and fires
`/remote-control`, which pairs it to the Claude app on your phone. Because the
session is detached it survives your laptop sleeping or SSH dropping — so you
can keep replying from your phone. The VM must be running for this, so only
`devbox down` when you're truly finished.

The `/remote-control` auto-fire is best-effort (it types into Claude's TUI). If
it can't confirm pairing it tells you to attach (`devbox claude`) and run
`/remote-control` yourself — one keystroke.

## Startup output

`devbox up` / `devbox code` print **month-to-date spend for the whole
subscription** (all resources, not just devbox). Set `DEVBOX_MONTHLY_CREDIT`
(e.g. `150` for VS Enterprise) to also see remaining credit — note Azure has no
API for the actual credit *balance* on these subs, so it's derived as
`credit - spend`.

`devbox code` and `devbox claude` always **reuse** a Claude session that's
already running (they never spawn a duplicate) and say so when they do.

## Tests

```sh
bash tests/test_devbox.sh
```

Dependency-free; mocks `az`/`ssh`/`tmux` so nothing touches real infrastructure.
