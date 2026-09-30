#!/usr/bin/env bash
# CI loop for one chapter: every part it declares, or just one.
#   test-lab.sh <chapter-number> [part]
#
# For each part, proves that:
#   1. the untouched lab FAILS verification (checks are real, not vacuous)
#   2. setup is idempotent (running it twice in a row works)
#   3. the reference solution PASSES verification
#   4. reset returns the lab to a failing starting state
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ch="${1:?chapter number}"
only="${2:-${LAB_PART:-}}"
part=""

fail() { echo "LAB TEST FAILED (chapter ${ch}${part:+ part ${part}}): $*" >&2; exit 1; }
run()  { bash "${here}/run-lab.sh" "$@"; }

# expect_verify_fails: verify must exit non-zero, and not with a usage error (2).
expect_verify_fails() {
  local rc=0
  run "$ch" verify "$part" || rc=$?
  ((rc != 0)) || fail "$1"
  ((rc != 2)) || fail "verify reported a usage error instead of failing checks"
}

parts="$(bash "${here}/lab-parts.sh" "$ch")" || exit 1
if [[ -n "$only" ]]; then
  list=("$only")
elif [[ -n "$parts" ]]; then
  read -ra list <<<"$parts"
else
  list=("")
fi

for part in "${list[@]}"; do
  echo "=== chapter ${ch}${part:+ part ${part}} ==="
  echo "### setup";                      run "$ch" setup "$part" || fail "setup failed"
  echo "### setup again (idempotency)";  run "$ch" setup "$part" || fail "second setup failed"
  echo "### verify on starting state (must fail)"
  expect_verify_fails "verify passed on the untouched lab"
  echo "### solve";                      run "$ch" solve "$part" || fail "solve failed"
  echo "### verify after solve (must pass)"
  run "$ch" verify "$part" || fail "verify failed after the reference solution"
  echo "### reset";                      run "$ch" reset "$part" || fail "reset failed"
  echo "### verify after reset (must fail)"
  expect_verify_fails "verify passed after reset"
done
part=""
echo "LAB TEST OK (chapter ${ch})"
