#!/usr/bin/env bash
set -euo pipefail
# Lightweight MythX runner wrapper. Requires mythx-cli or mythril installed.
# Usage: scripts/ci/run_mythx.sh [target_contract]

target=${1:-FusionLinker}

if command -v mythx >/dev/null 2>&1; then
  echo "Running mythx CLI against $target (mythx)..."
  mythx analyze --files ./ --contract "$target" --output mythx-report.json || true
  echo "mythx-report.json created (if any output)"
  exit 0
fi

if command -v myth >/dev/null 2>&1; then
  echo "Running myth (mythril) against $target..."
  myth analyze contracts/ --solidity-version 0.8 --output mythx-report.json || true
  echo "mythx-report.json created (if any output)"
  exit 0
fi

cat <<'MSG'
No MythX/Mythril CLI found in PATH.
To enable MythX integration in CI, install a CLI on the runner or provide a container image.
For local testing, install mythx-cli (npm) or mythril (pip):
  npm install -g mythx-cli
  or
  pip3 install mythril
MSG

exit 0
