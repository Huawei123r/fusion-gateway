#!/usr/bin/env bash
set -euo pipefail
# Simple local wrapper to run Echidna locally (requires cabal and echidna installed)
echidna-test ./ -c FusionLinker --contract FusionLinker --test-mode assertion --reporter json -o echidna-report.json
if ! command -v echidna-test >/dev/null 2>&1; then
  echo "echidna-test not found in PATH; install via 'cabal install echidna' or use the CI job"
  exit 2
fi

target=${1:-FusionLinker}
echo "Running Echidna for contract: $target"
echidna-test ./ -c "$target" --contract "$target" --test-mode assertion --reporter json -o echidna-${target}.json
ls -l echidna-${target}.json
