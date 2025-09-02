#!/usr/bin/env python3
"""
Simple Echidna JSON parser: exits with non-zero if counterexamples found.
Usage: parse_echidna.py echidna-report.json
"""
import json
import sys

if len(sys.argv) < 2:
    print("Usage: parse_echidna.py echidna-report.json")
    sys.exit(2)

infile = sys.argv[1]
try:
    with open(infile,'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Failed to read/parse {infile}: {e}")
    sys.exit(3)

# Echidna JSON format varies. Look for 'fails' or 'counterexamples' or 'failures'
counterexample_count = 0
if isinstance(data, dict):
    # common echidna outputs include keys like 'fails' mapping to lists
    for k in ('fails','failures','counterexamples','regressions'):
        if k in data and isinstance(data[k], list):
            counterexample_count += len(data[k])
    # fallback: scan for any 'counterexample' entries
    def scan(obj):
        c = 0
        if isinstance(obj, dict):
            for kk,vv in obj.items():
                if kk.lower().startswith('counter') and isinstance(vv, list):
                    c += len(vv)
                else:
                    c += scan(vv)
        elif isinstance(obj, list):
            for item in obj:
                c += scan(item)
        return c
    counterexample_count += scan(data)
else:
    print('Echidna report not dict; cannot parse')

print(json.dumps({'counterexamples': counterexample_count}, indent=2))
if counterexample_count > 0:
    print(f"ERROR: Echidna found {counterexample_count} counterexamples.")
    sys.exit(20)

print('No counterexamples found.')
sys.exit(0)
