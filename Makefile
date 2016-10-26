# encoding: UTF-8

# Determines whether the output is in color or not. To disable, set this to 0.
USE_COLOR = 1

ifeq ($(CURDIR),)
CURDIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
endif

ifndef PLATFORM
PLATFORM := $(shell uname | tr A-Z a-z)
endif

# Colors
ifneq ($(USE_COLOR),0)
YELLOW   = \033[0;33m
GREEN    = \033[0;32m
RED      = \033[0;31m
MAGENTA  = \033[0;35m
CYAN     = \033[0;36m
NO_COLOR = \033[0m
endif

# Get the latest commit.
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

# Get the version number from the code.
VERSION = $(strip $(shell cat VERSION))
ifndef VERSION
$(error echo You need to create a VERSION file to build a release)
endif

# Use the version number as the release tag.
TAG = $(VERSION)

# Detect if we are in a CI pipeline, if so skip checking the working directory.
ifndef CI
ifndef CIRCLECI

# Find out if the working directory is clean.
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
TAG_SUFFIX = -$(GIT_COMMIT)-dirty
endif

# If we're pusing to the registry, and we're going to mark it with the latest
# tag, it should exactly match a version release.
ifeq ($(MAKECMDGOALS), push)

# See what commit is tagged to match the version.
VERSION_COMMIT = $(strip $(shell git rev-list $(TAG) -n 1 | cut -c1-7))
ifneq ($(VERSION_COMMIT), $(GIT_COMMIT))
$(error echo You are trying to push a build based on commit '$(GIT_COMMIT)' but the tagged release version is '$(VERSION_COMMIT)')
endif

# Don't push to Docker Hub if this isn't a clean repo.
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo)
endif

else
# Add the commit ref for development builds. Mark as dirty if the working
# directory isn't clean.
TAG = $(VERSION)$(TAG_SUFFIX)
endif # ifeq ($(MAKECMDGOALS), push)
endif # ifndef CIRCLECI
endif # ifndef CI

# Load the latest tag, and set a default for TAG. The goal here is to ensure
# TAG is set as early possible, considering it's usually provided as an input
# anyway, but we want running "make" to *just work*.
include latest.mk

ifndef LATEST_TAG
$(error echo The LATEST_TAG *must* be set in latest.mk)
endif

ifeq "$(TAG)" "latest"
override TAG = $(LATEST_TAG)
endif

TAG ?= $(LATEST_TAG)

# Import configuration. config.mk must set the variables REGISTRY and
# REPOSITORY so the Makefile knows what to call your image. You can also set
# PUSH_REGISTRIES and PUSH_TAGS to customize what will be pushed. Finally, you
# can set any variable that'll be used by your build process, but make sure you
# export them so they're visible in build programs!
include config.mk

ifndef REGISTRY
$(error echo The REGISTRY *must* be set in config.mk)
endif

ifndef REPOSITORY
$(error echo The REPOSITORY *must* be set in config.mk)
endif

# Create $(TAG)/config.mk if you need to e.g. set environment variables
# depending on the tag being built. This is typically useful for things
# constants like a point version, a sha1sum, etc. (note that $(TAG)/config.mk
# is entirely optional).
-include versions/$(VERSION)/config.mk

# By default, we'll push the tag we're building, and the 'latest' tag if said
# tag is indeed the latest one. Set PUSH_TAGS in config.mk (or $(TAG)/config.mk)
# to override that behavior (note: you can't override the 'latest' tag).
PUSH_TAGS ?= $(TAG)

ifeq "$(TAG)" "$(LATEST_TAG)"
PUSH_TAGS += latest
endif

# By default, we'll push the registry we're naming the image after. You can
# override this in config.mk (or $(TAG)/config.mk)
PUSH_REGISTRIES ?= $(REGISTRY)

# Export what we're building for e.g. test scripts to use. Exporting other
# variables is the responsibility of config.mk and $(TAG)/config.mk.
export REPOSITORY
export REGISTRY
export TAG

ifeq "$(PLATFORM)" "darwin"
SIGIL_TGZ := sigil_0.4.0_Darwin_x86_64.tgz
SIGIL_SHA := 2b8b2768515a3a4d8ff7f615a03210fe523fc12733cc64548e757625b6f9bd4a
else
SIGIL_TGZ := sigil_0.4.0_Linux_x86_64.tgz
SIGIL_SHA := c503bc15fba88d08fe7ba350fc02e61c4757d13f349f56cf5b7977f8139d5843
endif
SIGIL_URL := https://github.com/gliderlabs/sigil/releases/download/v0.4.0/

# ******************************************************************************
# The rule that occurs first in the makefile is the default.
# By default, we want to build everything.
#
# Calling `make` will invoque the `all` rule.
# `all` depends on `build` by convention.
all : test

# We don't want `make` to get confused if a file named `all` should happen to
# exist, so we say that `all` is a `PHONY` target, i.e., a target that `make`
# should always try to update. We do that by making all a dependency of the
# special target `.PHONY`:
.PHONY : all prerequisite build .build_id .banner push test

# Print out a header.
.banner:
	@printf "$(YELLOW)---------------------------------------------------------\n"
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Repository" $(REPOSITORY)
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Build Tags" "$(PUSH_TAGS)"
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Registries" $(REGISTRY)
	@printf "$(YELLOW)---------------------------------------------------------\n"

prerequisite:
	@set -e; mkdir -p $HOME/bin; curl -sSLO $(SIGIL_URL)/$(SIGIL_TGZ)
	@echo $(SIGIL_SHA)  $(SIGIL_TGZ)
	@echo $(SIGIL_SHA)  $(SIGIL_TGZ) | sha256sum -c -
	@tar zxf $(SIGIL_TGZ) -C $(HOME)/bin/
	@rm -f $(SIGIL_TGZ)

# `build` depends on `.build_id`, that rule is a bit particular as it actually
# represent a file on disc. It is used as placeholder to know if we need to
# redo the build. In a “regular” Makefile scenario, we would have source file
# instead.
build: .banner .render .build_id

# If `.build_id` exists and didn’t change (mtime), then do nothing, otherwise,
# executre the rule.
#
# `.build_id` depends on `.`, meaning that if anything (mtime) changes in the
# local  directory, the rule will be reexecuted (upon next `make` call).
#
# The `.build_id` rule, when finish creates the `.build_id` file. So next time
# make is called, nothing will happen unless something changed within the
# directory.
.build_id: .
	@printf "\n$(CYAN)Pulling Image $(YELLOW): $(YELLOW)$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)$(NO_COLOR)\n"
	@docker pull $(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)
	@printf "\n$(CYAN)Building Image $(YELLOW): $(YELLOW)$(REGISTRY)/$(REPOSITORY):$(TAG)$(NO_COLOR)\n"
	@docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
								--build-arg VERSION=$(TAG) \
								--build-arg VCS_URL=`git config --get remote.origin.url` \
								--build-arg VCS_REF=$(GIT_COMMIT) \
								--tag	$(REGISTRY)/$(REPOSITORY):$(TAG) \
								--file versions/$(VERSION)/Dockerfile .
	@docker inspect --format '{{.Id}}' $(REGISTRY)/$(REPOSITORY):$(TAG) \
									> versions/$(VERSION)/.build_id
ifeq "$(TAG)" "$(LATEST_TAG)"
	@docker tag $(REGISTRY)/$(REPOSITORY):$(TAG) $(REGISTRY)/$(REPOSITORY):latest
endif

push: .banner build test
	for registry in $(PUSH_REGISTRIES); do \
		for tag in $(PUSH_TAGS); do \
			docker tag   $(REGISTRY)/$(REPOSITORY):$(TAG) \
                  $${registry}/$(REPOSITORY):$${tag}; \
			docker push $${registry}/$(REPOSITORY):$${tag}; \
		done \
	done

test: .banner build
	@printf "\n$(CYAN)Testing Image $(YELLOW): $(YELLOW)$(REGISTRY)/$(REPOSITORY):$(TAG)$(NO_COLOR)\n"
	@set -e; if [ -f 'test/run.bats' ]; then bats -p test/run.bats; break; fi

clean: .banner
	@printf "\n$(CYAN)Cleaning Image $(YELLOW): $(YELLOW)$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)$(NO_COLOR)\n"
	@rm -f .render .build Dockerfile
	@docker images -qa "$(REPOSITORY):$(TAG)" | xargs docker rmi -f
	@docker images -qa "$(REPOSITORY):latest" | xargs docker rmi -f

# Per-tag Dockerfile target. Look for Dockerfile or Dockerfile.tmpl in the root,
# and use it for $(TAG). We prioritize Dockerfile.tmpl over Dockerfile if
# both are present.
.render: $(TAG) prerequisite Dockerfile.tmpl Dockerfile
ifneq (,$(wildcard Dockerfile.tmpl))
	@sigil -f Dockerfile.tmpl \
						from=$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG) \
					> versions/$(VERSION)/Dockerfile
else
	@cp "Dockerfile" > versions/$(VERSION)/Dockerfile
endif

# Pseudo targets for Dockerfile and Dockerfile.tmpl. They don't technically
# create anything, but each warn if the other file is missing (meaning both
# files are missing).
Dockerfile.tmpl:
ifneq (,$(wildcard Dockerfile.tmpl))
	$(warning You must create a Dockerfile.tmpl or Dockerfile)
endif

Dockerfile:
ifneq (,$(wildcard Dockerfile))
	$(warning You must create a Dockerfile.tmpl or Dockerfile)
endif

$(TAG):
	@mkdir -p "versions/$(VERSION)"

# Calling `make` will invoque the `all` rule.
.DEFAULT_GOAL := all
