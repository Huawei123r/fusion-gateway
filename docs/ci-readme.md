CI & Security Automation

This project runs tests and security analysis automatically via GitHub Actions.

Workflows:
- `.github/workflows/ci.yml` - main workflow: build, test, SDK test, and Slither (produces `slither-report.json`).
- `.github/workflows/slither-pr.yml` - runs Slither on PRs and posts a parsed summary comment.

Artifacts:
- `gas_report.txt` uploaded by `ci.yml` as `gas-report`.
- `slither-report.json` and `slither-report.txt` uploaded by `ci.yml`.
- `slither-pr-parsed` artifact uploaded by `slither-pr.yml`.

How it works:
- CI runs `forge test` and Node.js tests.
- Slither runs in CI and on PRs; the PR workflow parses results and posts a summary comment.

Extending:
 - You can add more security tools (MythX, Echidna) by adding jobs similar to Slither.
  
Echidna fuzzing
Echidna runs weekly and on PRs via `.github/workflows/echidna.yml`. You can run it locally with:

MythX & Notifications
----------------------
Optional integrations:
- MythX: requires `MYTHX_API_KEY` secret configured in repository settings. When provided, the MythX workflow will run and upload reports.
- Slack notifications: set `SLACK_WEBHOOK` secret to enable notifications when monitored workflows fail.

Full weekly sweep & performance
--------------------------------
We added a weekly full test sweep (`.github/workflows/full-tests-schedule.yml`) which runs Forge tests, Node tests, Slither, and Echidna and uploads artifacts.

For local performance testing, run:

```bash
scripts/ci/run_perf.sh
```

This uses `autocannon` to load test the `offchain-service` (adjust port in script as needed).

```bash
scripts/ci/run_echidna.sh
```

Reports are uploaded as `echidna-report` artifacts in CI.

Parsing and gating
-------------------
CI will parse Echidna reports using `scripts/ci/parse_echidna.py`. If any counterexamples are found, the parser exits non-zero which can be used to fail the job and block merges until addressed.
- To enrich PR comments, update `scripts/ci/parse_slither.py` to include more details.
