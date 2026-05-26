#!/usr/bin/env bash
# Custom git merge driver for .claude-plugin/marketplace.json.
#
# Preserves fork-side identity fields (name, owner, description) while taking
# upstream for everything else (notably plugins[] entries when new versions
# land in upstream). Registered via scripts/setup-merge-driver.sh.
#
# Git invokes us with:
#   $1 = %O  (common ancestor; unused)
#   $2 = %A  (current branch / fork HEAD; "ours")
#   $3 = %B  (other branch / upstream HEAD; "theirs")
#
# We write the merged result back to $2 and exit 0 on success.

set -euo pipefail
ours="$2"
theirs="$3"

if ! command -v jq >/dev/null 2>&1; then
  echo "merge-marketplace-json.sh: jq not found; cannot run merge driver." >&2
  echo "Install jq, or resolve the conflict manually by editing $ours." >&2
  exit 1
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

# Strategy: take upstream (theirs) as base, then overlay our identity fields.
# This keeps any new top-level keys upstream may add (forward-compat).
jq -s '
  .[0] as $theirs
  | .[1] as $ours
  | $theirs
  | .name = $ours.name
  | .owner = $ours.owner
  | .description = $ours.description
' "$theirs" "$ours" > "$tmp"

mv "$tmp" "$ours"
exit 0
