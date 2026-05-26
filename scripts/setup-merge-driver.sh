#!/usr/bin/env bash
# One-time-per-clone setup for the marketplace.json custom merge driver.
#
# Registers the merge driver named in .gitattributes
# (`keep-fork-marketplace-fields`) with the local git config. Without this,
# upstream merges produce a manual conflict on .claude-plugin/marketplace.json
# every time. Idempotent: safe to re-run.
#
# Run after cloning the stratosjl/claudebase fork:
#   bash scripts/setup-merge-driver.sh

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
driver_script="$repo_root/scripts/merge-marketplace-json.sh"

if [ ! -f "$driver_script" ]; then
  echo "setup-merge-driver.sh: driver script not found at $driver_script" >&2
  exit 1
fi

chmod +x "$driver_script" || true

git config merge.keep-fork-marketplace-fields.name \
  "Keep fork-side marketplace.json identity fields; take upstream for plugins[] and other keys."
git config merge.keep-fork-marketplace-fields.driver \
  "$driver_script %O %A %B"

echo "Merge driver 'keep-fork-marketplace-fields' registered in $repo_root/.git/config."
echo "Conflicts on .claude-plugin/marketplace.json will auto-resolve at next upstream merge."
echo ""
echo "Sanity check: run 'git config --get merge.keep-fork-marketplace-fields.driver' to verify."
