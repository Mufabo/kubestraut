#!/usr/bin/env bash
# Shared helpers for lab scripts. Source this file; do not execute it.
#
#   source "$(dirname "${BASH_SOURCE[0]}")/../../../tools/lib.sh"
#
# Provides: logging, safety checks, waiting, namespace helpers, and the
# check/finish_checks framework used by every verify.sh.

set -o pipefail

BOOK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=/dev/null
source "${BOOK_ROOT}/versions.env"

if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_DIM=$'\033[2m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_DIM=""; C_RST=""
fi

info() { printf '%s\n' "${C_DIM}==>${C_RST} $*"; }
warn() { printf '%s\n' "${C_YEL}warn:${C_RST} $*" >&2; }
die()  { printf '%s\n' "${C_RED}error:${C_RST} $*" >&2; exit 1; }

require_cmd() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "required command not found: $c"
  done
}

# Refuse to touch a cluster that is not a lab cluster. Labs delete namespaces,
# so pointing them at a real cluster by accident would be destructive.
#   - Tier 1 contexts are named kind-<name>.
#   - Tier 2 environments export LAB_CONTEXT=<context name>.
#   - Override deliberately with LAB_ALLOW_ANY_CONTEXT=1.
require_lab_cluster() {
  require_cmd kubectl
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null)" || die "no kubectl context is set. Run: make cluster"
  if [[ "${LAB_ALLOW_ANY_CONTEXT:-0}" != "1" ]]; then
    if [[ -n "${LAB_CONTEXT:-}" ]]; then
      [[ "$ctx" == "$LAB_CONTEXT" ]] || die "context is '$ctx' but this lab expects '$LAB_CONTEXT'"
    else
      [[ "$ctx" == kind-* ]] || die "context '$ctx' is not a kind lab cluster. Switch with: kubectl config use-context kind-${CLUSTER_NAME}"
    fi
  fi
  kubectl cluster-info >/dev/null 2>&1 || die "cluster for context '$ctx' is not reachable"
}

# wait_for <description> <timeout-seconds> <command...>
wait_for() {
  local desc=$1 timeout=$2; shift 2
  local end=$((SECONDS + timeout))
  while ! "$@" >/dev/null 2>&1; do
    if ((SECONDS >= end)); then
      die "timed out after ${timeout}s waiting for: ${desc}"
    fi
    sleep 2
  done
}

# pod_phase_is <namespace> <pod> <phase>  (usable with wait_for and check)
pod_phase_is() {
  [[ "$(kubectl -n "$1" get pod "$2" -o jsonpath='{.status.phase}' 2>/dev/null)" == "$3" ]]
}

lab_teardown_ns() {
  local ns=$1
  info "Removing namespace ${ns} (if present)"
  kubectl delete namespace "$ns" --ignore-not-found --wait=true --timeout=180s >/dev/null
}

lab_create_ns() {
  local ns=$1
  kubectl create namespace "$ns" >/dev/null
  # Make the namespace the default for the reader's current context.
  kubectl config set-context --current --namespace="$ns" >/dev/null
  info "Namespace ${ns} created and set as the current context default"
}

# ---- check framework (used by verify.sh) ------------------------------------
CHECKS_PASSED=0
CHECKS_FAILED=0

# check <task-id> <description> <hint> <command...>
# The command runs in a subshell; success (exit 0) means PASS.
# It should be a function that chains conditions with && (set -e does not
# apply inside a tested command).
check() {
  local id=$1 desc=$2 hint=$3; shift 3
  if ( "$@" ) >/dev/null 2>&1; then
    printf '%s\n' "${C_GRN}PASS${C_RST}  Task ${id}: ${desc}"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
  else
    printf '%s\n' "${C_RED}FAIL${C_RST}  Task ${id}: ${desc}"
    printf '%s\n' "        hint: ${hint}"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
  fi
}

finish_checks() {
  local total=$((CHECKS_PASSED + CHECKS_FAILED))
  echo
  if ((CHECKS_FAILED == 0)); then
    printf '%s\n' "${C_GRN}All ${total} tasks passed.${C_RST}"
    return 0
  fi
  printf '%s\n' "${C_RED}${CHECKS_PASSED}/${total} tasks passed.${C_RST}"
  return 1
}
