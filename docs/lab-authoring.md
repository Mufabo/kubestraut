# Lab authoring guide

A lab is a small, disposable, self-checking scenario. Readers should be able to
wreck it and be back at the starting line in under a minute.

## The contract

| Script | Rules |
|---|---|
| `setup.sh` | Idempotent. Starts by tearing down previous state, then builds the exact starting state. Ends only when the lab is ready to use (wait for what must be running). |
| `reset.sh` | Tears down and calls `setup.sh`. Never leaves half a lab behind. |
| `verify.sh` | Read-only. One `check` per task. Prints PASS/FAIL and a hint on FAIL. Exits non-zero if any task fails. |
| `solve.sh` | Applies the reference solution non-interactively. Used by CI; also handy for readers who are truly stuck. |
| `teardown.sh` | *Optional.* Ends the lab: removes what it created and restores the reader's kubectl context and namespace. Run with `make teardown CH=n`. Required for labs that change the kubeconfig. |
| `solutions.md` | Human-readable solutions with the reasoning. |

`lab.env` defines:

```bash
LAB_NS=ch04-pods    # the namespace the lab owns (Tier 1)
LAB_TIER=1          # 1 = kind, 2 = multi-VM kubeadm
# LAB_CONTEXT=...   # Tier 2: the kubectl context the lab must run against
# LAB_PARTS="a b1"  # optional: split the lab into parts (see below)
```

## Rules

1. **Own your namespace.** Tier 1 labs create `LAB_NS` and put everything in it. Reset deletes that namespace. Never leave state in `default` or `kube-system`.
2. **Safety first.** Every script calls `require_lab_cluster` before touching anything. It refuses non-lab contexts.
3. **Cluster-scoped objects need cleanup.** If a lab creates a ClusterRole, PV, StorageClass, CRD, or node label/taint, `setup.sh` must remove the leftovers of a previous run and the chapter text must say so.
4. **No sleeping.** Use `wait_for` with a timeout and a description. Never `sleep 30` and hope.
5. **Pin everything.** Images with explicit tags (no `latest`), tool versions from `versions.env`.
6. **Local state lives in `lab/.state/`** (git-ignored), and reset removes it. Files the reader writes must go to a documented, fixed path (for example `/tmp/chNN-*.txt`); `setup.sh` removes it.
7. **Checks test outcomes, not commands.** Verify the resulting cluster state, so any valid approach (imperative, YAML, `edit`, `patch`) passes.
8. **Checks must be non-vacuous.** CI proves `verify.sh` fails on the untouched lab and passes after `solve.sh`. If a check passes before the reader does anything, it is a bug.
9. **Helpful hints.** A hint points at what to look at, not the answer.
10. **Randomize where copying would cheat.** If a task asks the reader to find a value, generate it at setup time and record it in `lab/.state/`.
11. **No `grep -q` at the end of a pipeline when `pipefail` is set.** `grep -q` exits at the first match, the upstream command can then die of SIGPIPE, and the pipeline intermittently reports failure. Capture the output first (`out="$(cmd)"`), then `grep -q ... <<<"$out"`, or compare with `[[ "$out" == *text* ]]`. This is a real race, not a style point.
12. **Fast.** Aim for `setup.sh` under 60 seconds on a warm kind cluster.

## Multi-part labs

A chapter can split its lab into independent parts, each with its own scenario,
namespace, checks, and reset. Declare them in `lab.env`:

```bash
LAB_PARTS="a b1 b2"     # the first one is the default
```

Readers pick a part with `PART`: `make lab CH=3 PART=b1`, `make verify CH=3 PART=b1`.
`tools/run-lab.sh` validates the part and exports it to your scripts as `$LAB_PART`.
Typical layout: `setup.sh`, `reset.sh`, `verify.sh`, `solve.sh` each dispatch on
`$LAB_PART` to `lab/parts/<part>.sh`.

Rules for parts:

- Parts must not depend on each other's state. Each gets its own namespace, named with the part (for example `ch03-b1-a`).
- `make test CH=n` runs the full loop for **every** part; `make test CH=n PART=x` runs one.
- A chapter without `LAB_PARTS` rejects `PART` with a usage error (exit code 2), and an unknown part is also a usage error, so a typo can never look like a passing or failing lab.

## Changing the reader's kubeconfig

Labs that create contexts or change the current context or namespace must undo
it. `tools/lib.sh` provides helpers:

```bash
lab_save_kubectx    "${here}/.state/kubectx"   # in setup.sh; keeps the ORIGINAL on repeat runs
lab_restore_kubectx "${here}/.state/kubectx"   # in teardown.sh (and reset if it rebuilds contexts)
lab_delete_contexts ch03-a ch03-b              # contexts the lab created
```

- Only create contexts whose names start with the chapter prefix (`ch03-`), so cleanup can never touch a reader's own contexts.
- `lab_create_ns` sets the current context's default namespace. Any lab that uses it should also call `lab_save_kubectx` first and provide a `teardown.sh`.
- `tools/test-lib.sh` unit-tests these helpers against a throwaway kubeconfig; it needs `kubectl` but no cluster (`make test-lib`).

## Skeletons

`setup.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${here}/../../../tools/lib.sh"
source "${here}/lab.env"

require_lab_cluster
lab_teardown_ns "$LAB_NS"
lab_create_ns "$LAB_NS"
# ... seed resources, then wait for readiness ...
info "Lab ready."
```

`verify.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${here}/../../../tools/lib.sh"
source "${here}/lab.env"
require_lab_cluster

t1() { [[ "$(kubectl -n "$LAB_NS" get pod web -o jsonpath='{.status.phase}')" == "Running" ]]; }
check 1 "pod web is running" "look at 'kubectl get pods'" t1

finish_checks
```

## Tier 2 labs

Tier 2 labs run against the multi-VM kubeadm environment in `envs/`. They set
`LAB_TIER=2` and `LAB_CONTEXT`. Reset restores VM snapshots instead of deleting
namespaces; the snapshot name is recorded in `lab.env` as `LAB_SNAPSHOT`.
Tier 2 environment work is Phase 2 in `ROADMAP.md`.
