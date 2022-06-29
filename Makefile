.DEFAULT_GOAL:=all

# Enforce bash as the shell for consistency
SHELL := bash
# Use bash strict mode
.SHELLFLAGS := -eu -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ORG := candlecorp
RELEASE ?= false
CROSS_VERSION := 0.2.2-darwin
CROSS_IMAGE:=$(ORG)/cross

ARCHITECTURES:=x86_64-unknown-linux-gnu \
		x86_64-pc-windows-gnu \
		aarch64-unknown-linux-gnu \
		aarch64-apple-darwin \
		x86_64-apple-darwin

##@ Building

.PHONY: all
all: $(ARCHITECTURES)

.PHONY: $(ARCHITECTURES)
$(ARCHITECTURES): ## Build cross image for specific architecture (see `make list`)
	echo "Building $@"
	@docker build docker -f docker/Dockerfile.$@ --build-arg VERSION=$(CROSS_VERSION) \
		-t $(CROSS_IMAGE):$@
ifeq ($(RELEASE),true)
		docker push $(CROSS_IMAGE):$@
endif

##@ Helpers

.PHONY: list
list: ## Display supported images
	@echo -e "\033[36mDockerfiles: \033[0m"
	@echo
	@echo -e "\033[36mCross-compilation architectures: \033[0m"
	@echo $(ARCHITECTURES) | xargs -n 1 echo

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[$$()a-zA-Z0-9_\-.*]+:.*?##/ { printf "  \033[36m%-32s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

