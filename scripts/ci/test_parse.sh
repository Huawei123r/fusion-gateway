#!/usr/bin/env bash
set -euo pipefail
PY=python3
TMP=$(mktemp)
cat > "$TMP" <<'JSON'
{"results":{"detectors":[{"check":"test","findings":[{"impact":"low"}]}]}}
JSON
$PY scripts/ci/parse_slither.py "$TMP" /tmp/parsed_test.json
cat /tmp/parsed_test.json
rm -f "$TMP" /tmp/parsed_test.json
echo OK
