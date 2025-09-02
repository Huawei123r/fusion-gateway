#!/usr/bin/env bash
set -euo pipefail
# Simple local wrapper to run Echidna locally (requires cabal and echidna installed)
if ! command -v echidna-test >/dev/null 2>&1; then
  echo "echidna-test not found in PATH; install via 'cabal install echidna' or use the CI job"
  exit 2
fi
# Example invocation: run against FusionLinker contract
echidna-test ./ -c FusionLinker --contract FusionLinker --test-mode assertion --reporter json -o echidna-report.json
ls -l echidna-report.json
