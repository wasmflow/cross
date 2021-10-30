.DEFAULT_GOAL:=help

CROSS_VERSION:=0.2.1
DOCKER_ORG:=vinodotdev
IMAGE:=$(DOCKER_ORG)/cross
RELEASE?=false

TARGET_ARCHS:=x86_64-unknown-linux-gnu \
		i686-unknown-linux-gnu \
		x86_64-pc-windows-gnu \
		i686-pc-windows-gnu \
		aarch64-unknown-linux-gnu \
		aarch64-apple-darwin \
		x86_64-apple-darwin

TARGET_DOCKERFILES:=$(foreach arch,$(TARGET_ARCHS),Dockerfile.$(arch))

##@ Building

.PHONY: build
build: $(TARGET_ARCHS) ## Build/push all images

.PHONY: $(TARGET_ARCHS)
$(TARGET_ARCHS): ## Build specific image
	@docker build docker -f docker/Dockerfile.$@ --build-arg VERSION=$(CROSS_VERSION) \
		-t $(IMAGE):$@
ifeq ($(RELEASE),true)
		docker push $(IMAGE):$@
endif

.PHONY:build-base
build-base: ## Make the build-base image
	docker build -f Dockerfile.build-base -t $(DOCKER_ORG)/build-base:latest .
ifeq ($(RELEASE),true)
		docker push $(DOCKER_ORG)/build-base:latest
endif

##@ Helpers

.PHONY: help

list: ## Display supported images
	@echo $(TARGET_ARCHS) | xargs -n 1 echo

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_\-.*]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
