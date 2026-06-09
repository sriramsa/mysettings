#!/usr/bin/env bash
#
# Tests for scripts/devbox. No external deps (no bats). Run:
#   bash tests/test_devbox.sh
#
# Strategy: source devbox (its main() does NOT run when sourced), override the
# _az/_ssh/_tmux/_curl/_code/_sleep wrappers with mocks that log their calls to
# a temp file, set the globals by hand, then call functions in subshells (so a
# die()/exit doesn't kill the harness) and assert on calls/output/exit codes.

# These tests source the devbox script and drive it: they set globals it
# consumes, read vars it assigns (az_sub), and define mock wrappers it calls
# indirectly. shellcheck can't follow the `source`, so silence those file-wide
# false positives (must precede the first command to be file-scoped):
# shellcheck disable=SC2034,SC2154,SC2329,SC2015

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
DEVBOX="$HERE/../scripts/devbox"

# shellcheck disable=SC1090
. "$DEVBOX"

PASS=0; FAIL=0
CALLS="$(mktemp)"
trap 'rm -f "$CALLS"' EXIT

reset_calls() { : > "$CALLS"; }
calls() { cat "$CALLS"; }
log_call() { printf '%s\n' "$*" >> "$CALLS"; }

ok() { PASS=$((PASS + 1)); printf '  ok   %s\n' "$1"; }
nok() { FAIL=$((FAIL + 1)); printf 'NOT OK %s\n         %s\n' "$1" "$2"; }

assert_eq()       { [ "$2" = "$3" ] && ok "$1" || nok "$1" "expected [$3], got [$2]"; }
assert_contains() { case "$2" in *"$3"*) ok "$1";; *) nok "$1" "[$2] does not contain [$3]";; esac; }
assert_missing()  { case "$2" in *"$3"*) nok "$1" "[$2] unexpectedly contains [$3]";; *) ok "$1";; esac; }
# run a function in a subshell, capture rc; output silenced
rc_of() { ( "$@" ) >/dev/null 2>&1; echo $?; }
out_of() { ( "$@" ) 2>&1; }

# ---- default mocks (tests override per case) ------------------------------
_sleep() { :; }                                   # never actually sleep
_az()   { log_call "az $*"; return 0; }
_ssh()  { log_call "ssh $*"; return 0; }
_tmux() { log_call "tmux $*"; return 0; }
_code() { log_call "code $*"; return 0; }
_curl() { log_call "curl $*"; return 0; }

# Helper to set a clean Mac context
as_mac() {
  CONTEXT="mac"; RG="rg1"; VM="vm1"; SUB=""; SSH_HOST="host.example"
  REMOTE_HOME="/home/me"; DEFAULT_PROJECT="proj"; compute_az_sub
}
as_vm() {
  CONTEXT="vm"; RG="rg1"; VM="vm1"; SUB="sub1"; REMOTE_HOME="/home/me"; compute_az_sub
}

echo "== pure helpers =="
assert_eq "remote_uri builds vscode-remote URI" \
  "$(remote_uri host /home/me mysettings)" \
  "vscode-remote://ssh-remote+host/home/me/src/mysettings"

assert_eq "billing: running -> charged" \
  "$(billing_note 'PowerState/running')" "RUNNING - being charged for compute"
assert_eq "billing: deallocated -> not charged" \
  "$(billing_note 'PowerState/deallocated')" "DEALLOCATED - not being charged for compute"
assert_contains "billing: stopped -> STILL charged warning" \
  "$(billing_note 'PowerState/stopped')" "STILL being charged"
assert_contains "billing: empty -> unknown" \
  "$(billing_note '')" "unknown"

echo "== context detection =="
# On VM: imds_field returns a name
imds_field() { case "$1" in name) echo "vm1";; resourceGroupName) echo "rg1";; subscriptionId) echo "sub1";; esac; }
CONTEXT=""; detect_context
assert_eq "detect_context -> vm when IMDS has a name" "$CONTEXT" "vm"
assert_eq "  picks up VM name from IMDS" "$VM" "vm1"
assert_eq "  picks up subscription from IMDS" "$SUB" "sub1"
# Off VM: imds_field returns nothing
imds_field() { echo ""; }
CONTEXT=""; detect_context
assert_eq "detect_context -> mac when IMDS empty" "$CONTEXT" "mac"

echo "== compute_az_sub =="
SUB=""; compute_az_sub
assert_eq "no --subscription when SUB empty" "${#az_sub[@]}" "0"
SUB="sub1"; compute_az_sub
assert_eq "passes --subscription when SUB set" "${az_sub[*]}" "--subscription sub1"

echo "== config loading =="
DEVBOX_CONFIG="$(mktemp)"
rc=$(rc_of load_mac_config)            # empty file -> missing RG/VM -> die
assert_eq "load_mac_config dies on empty config" "$rc" "1"
cat > "$DEVBOX_CONFIG" <<'EOF'
DEVBOX_RG="myrg"
DEVBOX_VM="myvm"
DEVBOX_SSH="h.example"
DEVBOX_REMOTE_HOME="/home/x"
DEVBOX_DEFAULT_PROJECT="p"
EOF
( load_mac_config; [ "$RG" = "myrg" ] && [ "$VM" = "myvm" ] && [ "$SSH_HOST" = "h.example" ] )
assert_eq "load_mac_config reads values" "$?" "0"
rm -f "$DEVBOX_CONFIG"; unset DEVBOX_CONFIG
DEVBOX_CONFIG="/nonexistent/devbox.env"
assert_eq "load_mac_config dies when file missing" "$(rc_of load_mac_config)" "1"
unset DEVBOX_CONFIG

# From here on, command tests use manually-set globals (via as_mac/as_vm), so
# stub the real config loader to a no-op — otherwise mac_setup would reload from
# ~/.config/devbox.env and clobber them (the real loader is exercised above).
load_mac_config() { :; }
require_az_login() { :; }

echo "== wrong-context guards =="
as_vm
assert_contains "up on VM is rejected" "$(out_of cmd_up)" "runs on your Mac"
assert_eq "  ...with non-zero exit" "$(rc_of cmd_up)" "1"
as_mac
assert_contains "claude on Mac is rejected" "$(out_of cmd_claude)" "runs on the VM"

echo "== down: mac path =="
as_mac
_az() { log_call "az $*"; case "$*" in *"account show"*) return 0;; *"get-instance-view"*) echo "PowerState/running";; esac; return 0; }
reset_calls; ( cmd_down ) >/dev/null 2>&1
assert_contains "mac down deallocates" "$(calls)" "az vm deallocate -g rg1 -n vm1"
assert_contains "mac down uses --no-wait" "$(calls)" "--no-wait"
assert_missing  "mac down does NOT use managed identity" "$(calls)" "login --identity"
# already deallocated -> short-circuit, no deallocate call
_az() { log_call "az $*"; case "$*" in *"account show"*) return 0;; *"get-instance-view"*) echo "PowerState/deallocated";; esac; return 0; }
reset_calls; ( cmd_down ) >/dev/null 2>&1
assert_missing "mac down skips when already deallocated" "$(calls)" "vm deallocate"

echo "== down: vm path (managed identity, REST - no az login) =="
as_vm
_curl() {
  log_call "curl $*"
  case "$*" in *"identity/oauth2/token"*) echo '{"access_token":"TOK123","token_type":"Bearer"}';; esac
  return 0
}
_az() { log_call "az $*"; return 0; }   # must NOT be used on the VM down path
reset_calls; ( cmd_down ) >/dev/null 2>&1
assert_contains "vm down fetches MI token from IMDS" "$(calls)" "identity/oauth2/token"
assert_contains "vm down POSTs to the deallocate endpoint" "$(calls)" "providers/Microsoft.Compute/virtualMachines/vm1/deallocate"
assert_contains "vm down sends the bearer token" "$(calls)" "Authorization: Bearer TOK123"
assert_missing  "vm down does NOT use 'az login'" "$(calls)" "az login"
# token missing -> clean failure, no deallocate POST
_curl() { log_call "curl $*"; return 0; }   # token endpoint returns nothing
reset_calls; out="$(out_of cmd_down)"
assert_contains "vm down errors clearly when no token" "$out" "managed-identity token"
assert_missing  "vm down skips deallocate when no token" "$(calls)" "/deallocate"

echo "== ensure_claude idempotency =="
as_vm
# Case A: session absent -> create + fire /remote-control
_tmux() {
  log_call "tmux $*"
  case "$1" in
    has-session) return 1;;                                  # absent
    show-environment) return 0;;                             # marker not set (empty)
    capture-pane) echo "? for shortcuts | Remote control: paired";;  # ready + paired
  esac
  return 0
}
reset_calls; ( ensure_claude ) >/dev/null 2>&1
assert_contains "ensure creates session when absent" "$(calls)" "tmux new-session -d -s claude"
assert_contains "ensure fires /remote-control" "$(calls)" "send-keys -t claude -l /remote-control"
assert_contains "ensure sets DONE marker after verify" "$(calls)" "set-environment -t claude DEVBOX_RC_DONE 1"

# Case B: marker already set -> no send-keys
_tmux() {
  log_call "tmux $*"
  case "$1" in
    has-session) return 0;;                                  # present
    show-environment) echo "DEVBOX_RC_DONE=1";;              # already paired
  esac
  return 0
}
reset_calls; out="$(out_of ensure_claude)"
assert_missing "ensure does not re-fire when marker set" "$(calls)" "send-keys"
assert_contains "ensure announces it is reusing the running session" "$out" "reusing"

# Case C: present but never paired, not ready -> no send-keys, safe fallback
_tmux() {
  log_call "tmux $*"
  case "$1" in
    has-session) return 0;;
    show-environment) return 0;;          # marker absent
    capture-pane) echo "loading...";;     # never shows a ready marker
  esac
  return 0
}
reset_calls; out="$(out_of ensure_claude)"
assert_missing "ensure does not blind-fire when not ready" "$(calls)" "send-keys"
assert_contains "ensure tells user how to pair manually" "$out" "/remote-control"

echo "== credits (subscription-wide spend) =="
as_mac; SUB="sub1"
_az() {
  log_call "az $*"
  case "$*" in
    *"CostManagement/query"*) printf '3.7986\tUSD\n';;
    *"account show"*) echo "sub1";;
  esac
  return 0
}
unset DEVBOX_MONTHLY_CREDIT 2>/dev/null || true
reset_calls; out="$(out_of print_credits)"
assert_contains "credits: shows month-to-date spend (rounded)" "$out" "3.80"
assert_contains "credits: shows currency" "$out" "USD"
assert_contains "credits: queries at SUBSCRIPTION scope (all resources)" "$(calls)" "subscriptions/sub1/providers/Microsoft.CostManagement"
DEVBOX_MONTHLY_CREDIT=150
out="$(out_of print_credits)"
assert_contains "credits: shows remaining when DEVBOX_MONTHLY_CREDIT set" "$out" "146.20"
unset DEVBOX_MONTHLY_CREDIT

echo "== dispatch =="
imds_field() { echo ""; }   # behave as Mac for dispatch
assert_eq "unknown command exits 2" "$(rc_of main bogus)" "2"
assert_contains "help lists commands" "$(out_of main help)" "devbox code"

echo
echo "-------------------------------------"
echo "PASS: $PASS   FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
