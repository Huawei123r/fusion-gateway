#!/usr/bin/env python3
"""
Simple Slither JSON parser to extract counts of issues by severity and type.
Usage: parse_slither.py input.json output.json
"""
import json
import sys

if len(sys.argv) < 3:
    print("Usage: parse_slither.py input.json output.json")
    sys.exit(2)

infile = sys.argv[1]
outfile = sys.argv[2]
mdfile = sys.argv[3] if len(sys.argv) > 3 else None

try:
    with open(infile, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Failed to read or parse '{infile}': {e}")
    sys.exit(3)

# slither JSON structure varies; we'll try to be defensive
issues = data.get('results', {}).get('detectors', [])
summary = {
    'total_issues': 0,
    'by_severity': {},
    'by_type': {},
}

for detector in issues:
    for finding in detector.get('findings', []):
        summary['total_issues'] += 1
        sev = finding.get('impact', 'unknown')
        t = detector.get('check', detector.get('name', 'unknown'))
        summary['by_severity'][sev] = summary['by_severity'].get(sev, 0) + 1
        summary['by_type'][t] = summary['by_type'].get(t, 0) + 1

# CI gating: fail if high-severity issues found
if summary['by_severity'].get('high', 0) > 0:
    print(f"ERROR: {summary['by_severity']['high']} high-severity issues found.")
    sys.exit(10)

with open(outfile, 'w') as f:
    json.dump(summary, f, indent=2)

print(json.dumps(summary, indent=2))

# Markdown summary output
if mdfile:
    md = ["## Slither Security Analysis Summary\n"]
    md.append(f"**Total Issues:** {summary['total_issues']}")
    md.append("\n**By Severity:**\n")
    for sev, count in summary['by_severity'].items():
        md.append(f"- {sev}: {count}")
    md.append("\n**By Type:**\n")
    for typ, count in summary['by_type'].items():
        md.append(f"- {typ}: {count}")
    md.append("\n---\n")
    with open(mdfile, 'w') as f:
        f.write('\n'.join(md))
