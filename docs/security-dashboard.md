# Fusion Gateway Security Dashboard

This page summarizes the latest automated security analysis results.

## Weekly Slither Scan
- The Slither scan runs every Monday via GitHub Actions.
- Results are uploaded as artifacts: JSON, parsed summary, and Markdown report.
- Review the latest scan in the Actions tab under 'Slither Scheduled Security Scan'.

## CI/PR Security Checks
- Every PR and push runs Slither analysis.
- High-severity issues will fail CI and block merges.
- PRs receive a Markdown summary comment with issue counts and types.

## How to Review
- Go to GitHub Actions > Slither Scheduled Security Scan for weekly results.
- For PRs, check the PR comment for a summary and download artifacts if needed.

## Improving Security
- Address all high-severity findings before merging.
- Use the parser script to generate custom reports: `scripts/ci/parse_slither.py`.
- Extend with additional tools (MythX, Echidna) for deeper analysis.

---
_Last updated: September 2, 2025_
