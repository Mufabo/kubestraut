# ROADMAP: The Kubestronaut Textbook

A hands-on textbook covering everything needed for the five certifications that make up **Kubestronaut**: **KCNA, KCSA, CKAD, CKA, CKS**.

- **Audience:** readers who already know Linux, basic web development, and containers.
- **Format:** one Markdown file per chapter, plus setup files for each chapter's lab environment.
- **Labs:** KodeKloud/Killercoda-style, repeatable and resettable with one command, self-checking.
- **Assessment:** end-of-chapter questions in every chapter, plus a mock exam per certification.

> **Before locking the outline:** verify each certification's current curriculum (domains, weights, Kubernetes version) on the CNCF/Linux Foundation curriculum repos. Update `docs/coverage-matrix.md` (see §6) whenever they change.
> **Already checked:** KCNA now has four domains (44/28/16/12) and CKA has five (25/15/20/10/30), per the official `cncf/curriculum` READMEs. The bullet-level PDFs still need to be transcribed into the coverage matrix.

---

## 1. Guiding principles
1. **Teach by topic, tag by exam.** Organize by subject; tag each chapter by the exams it serves.
2. **Every lab is disposable.** A reader can break anything and reset it quickly.
3. **Every lab is verifiable.** Tasks have automated PASS/FAIL checks.
4. **Every lab is tested in CI.** Reference solutions must pass verification before merge.
5. **Speed matters from the beginning.** Imperative kubectl, documentation navigation, and time budgeting are practiced throughout.
6. **Safety is part of the lab contract.** Destructive actions require verification of the intended disposable environment; author overrides are explicit and non-default.
7. **Cluster-scoped changes are explicit.** Labs declare ownership and cleanup for CRDs, ClusterRoles, PVs, StorageClasses, node labels/taints, and similar resources.
8. **Prefer reusable checks.** Common assertions should become declarative/machine-readable where practical; custom verify scripts remain for behavioral checks.
9. **One version pin, plus curriculum metadata.** Tool/Kubernetes versions live in versions.env; curriculum revision/date is tracked separately.
10. **Treat schedule estimates as hypotheses.** Progress is measured by tested slices and release gates, not chapter count.

## 2. Repository layout

```
kubestronaut-book/
├── ROADMAP.md
├── versions.env                 # K8s version + pinned tool versions
├── Makefile                     # make lab / reset / verify / solve CH=07
├── docs/
│   ├── style-guide.md
│   ├── chapter-template.md
│   ├── coverage-matrix.md       # every curriculum bullet -> chapter + lab
│   └── lab-authoring.md         # conventions for setup/reset/verify scripts
├── tools/
│   ├── lib.sh                   # shared shell helpers (log, assert, wait)
│   ├── render-questions.py      # questions/*.yaml -> chapter markdown
│   └── lint/                    # markdown + shellcheck + yamllint config
├── envs/
│   ├── kind/                    # Tier 1 cluster configs
│   ├── vagrant/                 # Tier 2 multi-VM kubeadm environment
│   └── devcontainer/            # Tier 3 Codespaces / hosted option
├── chapters/
│   └── 07-configmaps-secrets/
│       ├── 07-configmaps-secrets.md  # the chapter text (named after the chapter)
│       ├── questions.yaml       # end-of-chapter question bank
│       ├── manifests/           # starter YAML for the reader
│       └── lab/
│           ├── lab.env          # LAB_NS, LAB_TIER, ...
│           ├── setup.sh         # idempotent: builds the starting state
│           ├── reset.sh         # returns to the starting state
│           ├── verify.sh        # per-task PASS/FAIL
│           ├── solve.sh         # automated reference solution (CI)
│           └── solutions.md     # human-readable, kept separate to avoid spoilers
├── mock-exams/
│   ├── kcna/  kcsa/  ckad/  cka/  cks/
└── appendices/
```

---

## 3. Lab infrastructure
| Tier | Environment | Used for | Reset method |
|---|---|---|---|
| 1 | kind / k3d (multi-node) | Most workloads, config, services, storage, RBAC, scheduling | Namespace delete or cluster recreation |
| 2 | Multi-VM Linux kubeadm cluster | Cluster install, upgrades, etcd backup/restore, node troubleshooting, most CKS | VM snapshot / rebuild |
| 3 | **Canonical hosted implementation:** one documented devcontainer/Codespaces-compatible environment | Hosted fallback for readers without capable hardware | Rebuild/restart scenario |

Tier 2 is an implementation detail, not a curriculum requirement. Vagrant may be used, but should be validated by a proof of concept before becoming the supported path.

**Tier 2 POC:** validate cluster creation, node failure/recovery, upgrade, etcd backup/restore, and snapshot/rebuild on a supported host before scaling to all Tier 2 chapters.

**Reset contract:** setup is idempotent; reset restores the starting state; verify is read-only and reports PASS/FAIL; solve is the CI reference solution; solutions.md contains human-readable solutions.

**Lab safety contract:**
- Never silently mutate the user's current kubeconfig namespace/context; prefer explicit context and namespace arguments.
- Verify actual disposable cluster identity before destructive operations, not merely a context name.
- Delete only namespaces/resources owned by the lab.
- Cluster-scoped resources require an ownership/cleanup registry.
- `LAB_ALLOW_ANY_CONTEXT=1` is an explicit unsafe author/debug override.

**Lab quality loop:** setup → untouched verify-fail → solve → verify-pass → deliberately break → reset → verify-fail again → repeat. Include an unrelated sentinel resource in the test harness.

**Lab taxonomy:** tag tasks as CREATE, CONFIGURE, DEBUG, RECOVER, IMPLEMENT, SECURE, INVESTIGATE, or OPTIMIZE.

**Hardware:** state minimums in Chapter 3; point unsupported hardware to Tier 3.

## 4. Chapter template

Every chapter follows this structure:

1. **Header block:** exams served (tags), difficulty, estimated time, lab tier, prerequisites
2. **Learning objectives** (mapped to curriculum bullets)
3. **Concepts:** explanation with Mermaid diagrams
4. **Guided walkthrough:** commands with expected output
5. **Hands-on lab:** 3 to 6 tasks, each with a suggested time limit and difficulty label
6. **Exam tips:** imperative shortcuts, which docs pages to bookmark
7. **End-of-chapter questions:** 10 to 15 (multiple choice for KCNA/KCSA style; performance tasks for CKA/CKAD/CKS style)
8. **Further reading**

### Chapter definition of done
- [ ] Text reviewed against current curriculum bullets
- [ ] Commands executed on the pinned Kubernetes version
- [ ] setup/reset/verify implemented and idempotent
- [ ] verify is read-only and refuses unexpected cluster identity
- [ ] Cluster-scoped resources have explicit ownership/cleanup
- [ ] CI proves reference solution passes
- [ ] CI proves untouched verification fails
- [ ] CI proves verification leaves an unrelated sentinel unchanged
- [ ] Reset works after deliberate breakage and repeat cycles are deterministic
- [ ] Questions and explanations written
- [ ] Coverage matrix updated
- [ ] Reviewed by a target-level reader who was not the author

## 5. Chapter plan

Legend: **A** = KCNA, **S** = KCSA, **D** = CKAD, **C** = CKA, **X** = CKS. Tier = lab environment (1, 2, or none for conceptual).

### Part I: Foundations

| # | Chapter | Exams | Tier |
|---|---|---|---|
| 01 | Cloud-native landscape, the CNCF, and why Kubernetes exists | A | none |
| 02 | Kubernetes architecture: control plane, nodes, API server, etcd | A C | 1 |
| 03 | Lab setup and `kubectl` fluency (contexts, output formats, `explain`, dry-run) | A D C | 1 |
| 04 | Pods in depth | A D C | 1 |
| 05 | Controllers: ReplicaSets, Deployments, rollouts and rollbacks | A D C | 1 |
| 06 | Namespaces, labels, selectors, annotations | A D C | 1 |

### Part II: Building and running applications

| # | Chapter | Exams | Tier |
|---|---|---|---|
| 07 | ConfigMaps, Secrets, environment variables, downward API | D C | 1 |
| 08 | Jobs and CronJobs | D | 1 |
| 09 | Multi-container pods: init containers, sidecars, patterns | D | 1 |
| 10 | Probes, requests/limits, QoS classes | D C | 1 |
| 11 | Services and cluster DNS | A D C | 1 |
| 12 | Ingress and Gateway API | D C | 1 |
| 13 | Storage basics: volumes, PV, PVC, StorageClass | D C | 1 |
| 14 | Helm and Kustomize | D C | 1 |
| 15 | Developer observability: logs, metrics, debugging applications | A D | 1 |
| 16 | Application delivery: CI/CD, GitOps (Argo CD, Flux), deployment strategies | A D | 1 |

### Part III: Cluster administration

| # | Chapter | Exams | Tier |
|---|---|---|---|
| 17 | Scheduling: taints, tolerations, affinity, topology spread, priority, static pods | C | 1 |
| 18 | Installing a cluster with kubeadm | C | 2 |
| 19 | Cluster upgrades and node maintenance (cordon, drain) | C | 2 |
| 20 | etcd backup and restore | C | 2 |
| 21 | Networking internals: CNI, kube-proxy, NetworkPolicy, CoreDNS | A C | 1/2 |
| 22 | Storage internals: CSI, dynamic provisioning, access modes | C | 1 |
| 23 | RBAC and ServiceAccounts | C X | 1 |
| 24 | CRDs, operators, and extension interfaces (CRI, CNI, CSI) | A C | 1 |
| 25 | Autoscaling: HPA, VPA, cluster autoscaler concepts | A C | 1 |
| 26 | Troubleshooting I: applications and networking | C | 1/2 |
| 27 | Troubleshooting II: nodes, kubelet, control plane, certificates | C | 2 |
| 28 | Cloud-native architecture: service mesh, serverless, personas, community and governance | A | none |

### Part IV: Security

| # | Chapter | Exams | Tier |
|---|---|---|---|
| 29 | Cloud-native security model: 4Cs, threat modeling, compliance frameworks | S | none |
| 30 | Cluster setup hardening: CIS benchmark (kube-bench), API server flags, TLS | S X | 2 |
| 31 | AuthN, AuthZ, and admission control (ValidatingAdmissionPolicy, OPA Gatekeeper, Kyverno) | S X | 1/2 |
| 32 | System hardening: AppArmor, seccomp, host OS footprint | X | 2 |
| 33 | Microservice hardening: Pod Security Standards, securityContext, secrets management, sandboxed runtimes | S X | 2 |
| 34 | Supply chain security: image scanning, signing, SBOMs, image admission policy | S X | 1/2 |
| 35 | Runtime security, monitoring, and auditing: Falco, audit logs, immutability, incident response | S X | 2 |
| 36 | Network security in depth: default-deny, mTLS, encryption in transit | S X | 1/2 |

### Part V: Exam readiness

| # | Chapter | Exams | Tier |
|---|---|---|---|
| 37 | Terminal speed: aliases, `vim`, `tmux`, `jq`/`yq`, imperative commands | D C X | 1 |
| 38 | Navigating the allowed documentation | D C X | none |
| 39 | Exam logistics and study plans per certification | all | none |
| M1-M5 | Mock exams: KCNA, KCSA (question banks); CKAD, CKA, CKS (timed performance-based) | all | 1/2 |

### Appendices

Command cheat sheet · YAML snippets · JSONPath reference · glossary · solution index · troubleshooting the lab environments

---

## 6. Coverage matrix
Maintain `docs/coverage-matrix.md` with one row per curriculum bullet:
| Exam | Curriculum revision/date | Domain | Bullet | Chapter | Lab task | Task type | Question IDs | Status |
|---|---|---|---|---|---|---|---|---|
Review it at every phase and release. No bullet should silently disappear during reorganization; conceptual-only material must have an explicit status. Review Chapters 21, 24, and 31 for overloaded skill loops and split their lab scenarios without gratuitous chapter renumbering.

## 7. Phases and milestones
Estimates are planning hypotheses; phases exit on release gates, not chapter counts.

### Phase 0: ENGINE — lab contract and pilot (2–3 weeks)
- [ ] CI, question schema validation, coverage metadata
- [ ] Disposable-cluster identity and explicit-context safety
- [ ] Cluster-scoped cleanup contract
- [ ] Chapter 04 reaches the full definition of done
- **Gate:** a stranger can run, verify-fail, solve, break, reset, and repeat without affecting a sentinel or non-lab context.

### Phase 1A: CORE — Foundations
- [ ] Chapters 01–06
- [ ] Timed drills, docs navigation, imperative-command practice
- [ ] First external testers
- **Release:** v0.1 Foundations.

### Phase 1B: APPLICATIONS — Chapters 07–16
- [ ] Chapters 07–16
- [ ] Canonical Tier 3 implementation
- [ ] Reusable declarative lab checks
- [ ] External CKAD-oriented beta slice
- **Release:** v0.2 Applications.

### Phase 2: ADMIN — Tier 2 POC, then Chapters 17–28
- [ ] Tier 2 POC first
- [ ] Supported host/provider matrix
- [ ] Chapters 17–28 with real troubleshooting/recovery tasks
- **Release:** v0.3 Administration.

### Phase 3: SECURITY — Chapters 29–36
- [ ] Pin/test security tooling
- [ ] Teach concepts/workflows, not vendor commands alone
- [ ] Document supported host-dependent environment
- **Release:** v0.4 Security.

### Phase 4: EXAM SYSTEM — Chapters 37–39 and mocks
- [ ] Chapters 37–39
- [ ] Five mock exams and timing data
- [ ] `make exam`: timed, no learner hints, explicit PASS/FAIL, same lab contract
- [ ] Docs-navigation and terminal-speed drills are synthesized here, not introduced here
- **Release:** v0.5 Full Coverage.

### Phase 5: VALIDATION — beta and release
- [ ] 3–5 beta readers
- [ ] Supported Linux/macOS/Windows-WSL paths tested
- [ ] Full curriculum/Kubernetes/tool re-verification
- [ ] Errata and release checklist
- **Release:** v1.0 after metrics below.

### Success metrics
- 100% of included labs pass the full setup/verify/solve/break/reset loop.
- 100% of included curriculum bullets are mapped with explicit conceptual status where applicable.
- All verify scripts are read-only.
- Advertised platform matrix is actually tested.
- No broken internal links and clean-checkout prerequisites work.
- External learner blockers are tracked and fixed.
- Each release records curriculum revision/date and Kubernetes/tool versions.

**Planning note:** retain the original 8–10 month figure only as a rough envelope; do not defer external validation until all 39 chapters exist.

## 8. Risks and mitigations
| Risk | Mitigation |
|---|---|
| Curriculum/Kubernetes changes | versions.env + curriculum revision metadata + CI |
| Destructive lab targets a real cluster | Actual cluster identity check + explicit contexts + safe refusal |
| Cluster-scoped resources leak | Ownership/cleanup registry |
| Tier 2 is brittle/host-specific | Early POC and documented support matrix |
| Tier 3 fragments into competing implementations | One canonical hosted implementation first |
| Lab scripts rot | CI plus scheduled runs |
| Security tools change | Pin versions; teach workflows/concepts |
| Author-only success | External testers on supported platforms |
| Scope creep | Coverage-matrix mapping or Further reading |
| Overloaded chapters | Split lab scenarios before renumbering |
| Exam-content copying | Original questions/scenarios from public curricula only |

## 9. Immediate next steps

1. Finish lab safety: disposable-cluster identity, no kubeconfig namespace mutation, read-only verification, cluster-scoped cleanup.
2. Run Chapter 04 against a real kind cluster through the full test loop.
3. Add `make doctor` for prerequisites, versions, runtime, cluster state, and context safety.
4. Harden the test harness with a sentinel, deterministic repeat cycles, and useful debug output.
5. Deliver Foundations (01–06), then Applications (07–16); start external testing before all 16 exist.
6. Prototype Tier 2 before most administration chapters.
7. Choose and document the canonical Tier 3 implementation.
8. Introduce timed mode and docs-navigation drills before Part V.
9. Populate the coverage matrix from the current five curricula with revision/date.
10. Add tests for chapter discovery, path resolution, question validation, version parsing, and context validation.
11. Use release gates for v0.1, v0.2, v0.3, v0.4, v0.5, and v1.0.
