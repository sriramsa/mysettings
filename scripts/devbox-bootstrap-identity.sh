#!/usr/bin/env bash
#
# One-time setup: give the devbox VM a system-assigned managed identity that is
# allowed to deallocate ITSELF, so `devbox down` works from on the VM.
#
# Run this ON YOUR MAC, where `az login` is already done. Safe to re-run.
#
#   ./devbox-bootstrap-identity.sh
#
# It reads ~/.config/devbox.env (the same untracked config devbox uses) and
# scopes the role to the single VM resource - nothing else in the group.

set -euo pipefail

CONFIG="${DEVBOX_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/devbox.env}"
[ -f "$CONFIG" ] || { echo "Missing $CONFIG (copy devbox.env.example there and fill it in)." >&2; exit 1; }
# shellcheck disable=SC1090
. "$CONFIG"

: "${DEVBOX_RG:?set DEVBOX_RG in $CONFIG}"
: "${DEVBOX_VM:?set DEVBOX_VM in $CONFIG}"

SUBARG=(); [ -n "${DEVBOX_SUB:-}" ] && SUBARG=(--subscription "$DEVBOX_SUB")

command -v az >/dev/null 2>&1 || { echo "Azure CLI not found. Install it first." >&2; exit 1; }
az account show >/dev/null 2>&1 || { echo "Not logged in. Run: az login" >&2; exit 1; }

echo "Assigning a system-assigned managed identity to $DEVBOX_VM..."
az vm identity assign -g "$DEVBOX_RG" -n "$DEVBOX_VM" ${SUBARG[@]+"${SUBARG[@]}"} -o none

PRINCIPAL_ID="$(az vm show -g "$DEVBOX_RG" -n "$DEVBOX_VM" ${SUBARG[@]+"${SUBARG[@]}"} --query identity.principalId -o tsv)"
VM_ID="$(az vm show -g "$DEVBOX_RG" -n "$DEVBOX_VM" ${SUBARG[@]+"${SUBARG[@]}"} --query id -o tsv)"

echo "Granting 'Virtual Machine Contributor' scoped to the VM only..."
az role assignment create \
  --assignee-object-id "$PRINCIPAL_ID" \
  --assignee-principal-type ServicePrincipal \
  --role "Virtual Machine Contributor" \
  --scope "$VM_ID" \
  -o none

echo "Done. 'devbox down' on the VM can now deallocate it via the managed identity."
echo "(Role propagation can take up to a minute.)"
