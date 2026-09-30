#!/usr/bin/env bash
# Print the chapter directory for a chapter number, e.g. `lab-path.sh 4` -> chapters/04-pods
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
n="${1:?usage: lab-path.sh <chapter-number>}"
n="$(printf '%02d' "$((10#$n))")"
dir="$(compgen -G "${root}/chapters/${n}-*" | head -n1 || true)"
[[ -n "$dir" ]] || { echo "no chapter directory matches ${n}-*" >&2; exit 1; }
echo "$dir"
