#!/usr/bin/env bash
# Run one of a chapter's lab scripts.
#   run-lab.sh <chapter-number> <setup|reset|verify|solve>
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dir="$(bash "${here}/lab-path.sh" "${1:?chapter number}")"
action="${2:?setup|reset|verify|solve}"
script="${dir}/lab/${action}.sh"
[[ -f "$script" ]] || { echo "missing ${script}" >&2; exit 1; }
exec bash "$script"
