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
- You can add more security tools (mythx, echidna, fuzzing) by adding jobs similar to Slither.
 - You can add more security tools (MythX, Echidna) by adding jobs similar to Slither.
  
Echidna fuzzing
----------------
Echidna runs weekly and on PRs via `.github/workflows/echidna.yml`. You can run it locally with:

```bash
scripts/ci/run_echidna.sh
```

Reports are uploaded as `echidna-report` artifacts in CI.
- To enrich PR comments, update `scripts/ci/parse_slither.py` to include more details.
