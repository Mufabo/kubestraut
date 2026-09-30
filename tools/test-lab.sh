#!/usr/bin/env bash
# CI loop for one chapter. Proves that:
#   1. the untouched lab FAILS verification (checks are real, not vacuous)
#   2. the reference solution PASSES verification
#   3. reset returns the lab to a failing starting state
#   4. setup is idempotent (running it twice in a row works)
#
#   test-lab.sh <chapter-number>
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
run() { bash "${here}/run-lab.sh" "$@"; }
ch="${1:?chapter number}"
fail() { echo "LAB TEST FAILED (chapter ${ch}): $*" >&2; exit 1; }

echo "### setup";                      run "$ch" setup || fail "setup failed"
echo "### setup again (idempotency)";  run "$ch" setup || fail "second setup failed"
echo "### verify on starting state (must fail)"
run "$ch" verify && fail "verify passed on the untouched lab"
echo "### solve";                      run "$ch" solve || fail "solve failed"
echo "### verify after solve (must pass)"
run "$ch" verify || fail "verify failed after the reference solution"
echo "### reset";                      run "$ch" reset || fail "reset failed"
echo "### verify after reset (must fail)"
run "$ch" verify && fail "verify passed after reset"
echo "LAB TEST OK (chapter ${ch})"
