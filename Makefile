# Usage: make help
include versions.env
export

CH ?=
SHELL := /usr/bin/env bash

.PHONY: help cluster cluster-delete lab reset verify solve test test-tier1 questions questions-check lint

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*## ' Makefile | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'
	@echo; echo "Chapter targets need CH=<number>, e.g. make lab CH=4"

cluster: ## Create the Tier 1 kind cluster (idempotent)
	@kind get clusters | grep -qx "$(CLUSTER_NAME)" && echo "cluster $(CLUSTER_NAME) already exists" || \
	  kind create cluster --name "$(CLUSTER_NAME)" --image "$(KIND_NODE_IMAGE)" --config envs/kind/cluster.yaml

cluster-delete: ## Delete the Tier 1 kind cluster
	kind delete cluster --name "$(CLUSTER_NAME)"

lab: ## Set up the lab for CH (also resets it if it already exists)
	@bash tools/run-lab.sh "$(CH)" setup

reset: ## Reset the lab for CH to its starting state
	@bash tools/run-lab.sh "$(CH)" reset

verify: ## Check your work for CH
	@bash tools/run-lab.sh "$(CH)" verify

solve: ## Apply the reference solution for CH (spoilers!)
	@bash tools/run-lab.sh "$(CH)" solve

test: ## Run the full setup/verify/solve/reset loop for CH (author/CI use)
	@bash tools/test-lab.sh "$(CH)"

test-tier1: ## Run the loop for every Tier 1 chapter
	@set -e; for n in $$(bash tools/list-chapters.sh 1); do bash tools/test-lab.sh $$n; done

questions: ## Render questions.yaml into every chapter README
	@python3 tools/render-questions.py

questions-check: ## Fail if any chapter README is out of date with its questions.yaml
	@python3 tools/render-questions.py --check

lint: ## shellcheck, yamllint, markdownlint
	@shellcheck tools/*.sh chapters/*/lab/*.sh
	@yamllint -c .yamllint .
	@markdownlint-cli2 "**/*.md" "#node_modules"
