# Coverage matrix

Purpose: prove that every curriculum item for all five exams is covered by a
chapter, a lab task, and questions. This file is the source of truth for "does
the book cover everything?".

## How to read this file

- **Domain weights** below were taken from the official `cncf/curriculum` repository READMEs.
- **Topic rows** are *topic-level*, not verbatim curriculum bullets. The bullet-level curriculum PDFs could not be retrieved when this file was started. **Before v1.0, replace each topic row with the verbatim bullets from the current curriculum PDFs** and re-check the mapping.
- Status values: `planned`, `drafted` (written, not yet run on a real cluster or reviewed), `verified` (lab passes CI on a real cluster and a beta reader has completed it).
- Re-verify weights whenever CNCF revises a curriculum.

## KCNA (four domains; per the official README)

| Domain | Weight |
|---|---|
| Kubernetes Fundamentals | 44% |
| Container Orchestration | 28% |
| Cloud Native Application Delivery | 16% |
| Cloud Native Architecture | 12% |

Note: the KCNA curriculum was reorganized from five domains to four (the older split had Observability as its own domain). Older study material may use the old split.

| Domain | Topic (verify against PDF) | Chapter | Lab task | Questions | Status |
|---|---|---|---|---|---|
| Kubernetes Fundamentals | Kubernetes architecture and components | 02 | 02/T1-T3 | ch02-q01..q08 | drafted |
| Kubernetes Fundamentals | Kubernetes API, API groups and versions | 02 | 02/T5 | ch02-q06, q09, q11 | drafted |
| Kubernetes Fundamentals | Scheduling (basic role of the scheduler) | 02 | 02/T4 | ch02-q02, q12 | drafted |
| Kubernetes Fundamentals | Containers and orchestration fundamentals | 01 | none | ch01-q05, q06 | drafted |
| Container Orchestration | Container orchestration fundamentals (why) | 01 | none | ch01 (whole chapter) | drafted |
| Container Orchestration | Runtime, CRI | 01 | none | ch01-q04 | drafted |
| Cloud Native Architecture | Cloud native principles (12-factor, microservices, immutable infra) | 01 | none | ch01-q07..q09, q15 | drafted |
| Cloud Native Architecture | Community, governance, SIGs, KEPs, maturity | 01 | exploration exercise | ch01-q03, q12..q14 | drafted |
| Cloud Native Architecture | Open standards (OCI, CRI, CNI, CSI) | 01 | none | ch01-q04, q05 | drafted |
| Cloud Native Architecture | Ecosystem projects by category | 01 | exploration exercise | ch01-q10, q11 | drafted |
| Cloud Native Architecture | Autoscaling, serverless, personas | 25, 28 | tbd | tbd | planned |
| Cloud Native Application Delivery | GitOps, CI/CD, application delivery | 16 | tbd | tbd | planned |

## CKA (five domains; per the official README)

| Domain | Weight |
|---|---|
| Cluster Architecture, Installation & Configuration | 25% |
| Workloads & Scheduling | 15% |
| Services & Networking | 20% |
| Storage | 10% |
| Troubleshooting | 30% |

| Domain | Topic (verify against PDF) | Chapter | Lab task | Questions | Status |
|---|---|---|---|---|---|
| Cluster Architecture, Installation & Configuration | Understand cluster components and their roles | 02 | 02/T1-T3 | ch02-q01..q08 | drafted |
| Cluster Architecture, Installation & Configuration | Static Pods and the kubelet manifest directory | 02, 17 | 02/T3 | ch02-q07 | drafted (17 planned) |
| Cluster Architecture, Installation & Configuration | kubeconfig and contexts | 02, 03 | tbd | ch02-q10 | drafted (03 planned) |
| Workloads & Scheduling | Pods | 04 | 04/T1-T5 | ch04-q01..q12 | drafted |
| Troubleshooting | Diagnosing failing Pods (image pull, crash loops, pending) | 04, 26 | 04/T2 | ch04-q03, q11 | drafted (26 planned) |
| All other CKA rows | | | | | planned |

## CKAD, CKS, KCSA

Not yet mapped. Before starting Phase 1, copy each exam's domains and weights
from its `cncf/curriculum` README into this file, then add topic rows.

## Kubernetes version

The book pins one minor version in `versions.env`. Re-check the version each
exam is currently written against before each edition; third-party guides
reported CKA on v1.35 at the time this file was started, which is why v1.35 is the current pin.
