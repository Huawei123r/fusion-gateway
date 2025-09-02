#!/usr/bin/env bash
set -euo pipefail
# Local performance test for offchain-service using autocannon
if ! command -v autocannon >/dev/null 2>&1; then
  echo "autocannon not found. Install with 'npm i -g autocannon'"
  exit 2
fi
# Start offchain service (assumes it can be started with 'npm start' in offchain-service)
pushd offchain-service >/dev/null
npm ci
npm run start &
PID=$!
sleep 2
popd >/dev/null

# Run autocannon against localhost:3000 (adjust port as needed)
autocannon -c 50 -d 10 http://localhost:3000/

# Teardown
kill $PID || true
echo "Performance test done"
