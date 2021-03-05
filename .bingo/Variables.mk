# Auto generated binary variables helper managed by https://github.com/bwplotka/bingo v0.3.1. DO NOT EDIT.
# All tools are designed to be build inside $GOBIN.
BINGO_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GOPATH ?= $(shell go env GOPATH)
GOBIN  ?= $(firstword $(subst :, ,${GOPATH}))/bin
GO     ?= $(shell which go)

# Bellow generated variables ensure that every time a tool under each variable is invoked, the correct version
# will be used; reinstalling only if needed.
# For example for bingo variable:
#
# In your main Makefile (for non array binaries):
#
#include .bingo/Variables.mk # Assuming -dir was set to .bingo .
#
#command: $(BINGO)
#	@echo "Running bingo"
#	@$(BINGO) <flags/args..>
#
BINGO := $(GOBIN)/bingo-v0.3.1
$(BINGO): $(BINGO_DIR)/bingo.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/bingo-v0.3.1"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=bingo.mod -o=$(GOBIN)/bingo-v0.3.1 "github.com/bwplotka/bingo"

GOIMPORTS := $(GOBIN)/goimports-v0.1.0
$(GOIMPORTS): $(BINGO_DIR)/goimports.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/goimports-v0.1.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=goimports.mod -o=$(GOBIN)/goimports-v0.1.0 "golang.org/x/tools/cmd/goimports"

GOLINT := $(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5
$(GOLINT): $(BINGO_DIR)/golint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=golint.mod -o=$(GOBIN)/golint-v0.0.0-20201208152925-83fdc39ff7b5 "golang.org/x/lint/golint"

JB := $(GOBIN)/jb-v0.4.0
$(JB): $(BINGO_DIR)/jb.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jb-v0.4.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jb.mod -o=$(GOBIN)/jb-v0.4.0 "github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"

JSONNET_LINT := $(GOBIN)/jsonnet-lint-v0.17.0
$(JSONNET_LINT): $(BINGO_DIR)/jsonnet-lint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnet-lint-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnet-lint.mod -o=$(GOBIN)/jsonnet-lint-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnet-lint"

JSONNET := $(GOBIN)/jsonnet-v0.17.0
$(JSONNET): $(BINGO_DIR)/jsonnet.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnet-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnet.mod -o=$(GOBIN)/jsonnet-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnet"

JSONNETFMT := $(GOBIN)/jsonnetfmt-v0.17.0
$(JSONNETFMT): $(BINGO_DIR)/jsonnetfmt.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnetfmt-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnetfmt.mod -o=$(GOBIN)/jsonnetfmt-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnetfmt"

KUBECTX := $(GOBIN)/kubectx-v0.9.1
$(KUBECTX): $(BINGO_DIR)/kubectx.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/kubectx-v0.9.1"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=kubectx.mod -o=$(GOBIN)/kubectx-v0.9.1 "github.com/ahmetb/kubectx/cmd/kubectx"

KUBENS := $(GOBIN)/kubens-v0.9.1
$(KUBENS): $(BINGO_DIR)/kubens.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/kubens-v0.9.1"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=kubens.mod -o=$(GOBIN)/kubens-v0.9.1 "github.com/ahmetb/kubectx/cmd/kubens"

KUBEVAL := $(GOBIN)/kubeval-v0.0.0-20200515185822-7721cbec724c
$(KUBEVAL): $(BINGO_DIR)/kubeval.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/kubeval-v0.0.0-20200515185822-7721cbec724c"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=kubeval.mod -o=$(GOBIN)/kubeval-v0.0.0-20200515185822-7721cbec724c "github.com/instrumenta/kubeval"

SHFMT := $(GOBIN)/shfmt-v3.2.2
$(SHFMT): $(BINGO_DIR)/shfmt.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/shfmt-v3.2.2"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=shfmt.mod -o=$(GOBIN)/shfmt-v3.2.2 "mvdan.cc/sh/v3/cmd/shfmt"

TK := $(GOBIN)/tk-v0.14.0
$(TK): $(BINGO_DIR)/tk.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/tk-v0.14.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=tk.mod -o=$(GOBIN)/tk-v0.14.0 "github.com/grafana/tanka/cmd/tk"

