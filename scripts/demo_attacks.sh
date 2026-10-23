#!/usr/bin/env bash
# ShorlyNot VTU-QFF-HC-0085 One-Shot Attack Demonstration Runner
set -e

echo "[*] Executing ShorlyNot One-Shot Attack & Defense Demonstration..."
python scripts/demo_attacks.py "$@"
