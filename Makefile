# encoding: UTF-8
SHELL := /bin/bash -euo pipefail

# Determines whether the output is in color or not. To disable, set this to 0.
USE_COLOR = 1

ifdef DEBUG
  this_file := $(lastword $(MAKEFILE_LIST))
  $(warning $(this_file))
endif

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
ifneq ($(CI), $(CIRCLECI))
  TAG_OPTS = -f
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
endif # ifneq ($(CI), $(CIRCLECI))

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

DOCKERFILE = versions/$(VERSION)/Dockerfile
BUILD_ID = versions/$(VERSION)/.build_id

# ******************************************************************************
# The rule that occurs first in the makefile is the default.
# By default, we want to build everything.
#
# Calling `make` will invoque the `all` rule.
# `all` depends on `build` by convention.
all : deps build test push publish

# Print out a header.
banner:
	@printf "$(YELLOW)---------------------------------------------------------\n"
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Repository" $(REPOSITORY)
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Build Tags" "$(PUSH_TAGS)"
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Registries" $(REGISTRY)
	@printf "$(CYAN)%13s $(YELLOW): $(GREEN)%-15s\n" "Credentials" $(CREDENTIALS)
	@printf "$(YELLOW)---------------------------------------------------------\n"

deps: banner
	@printf "\n$(CYAN)Pulling Image $(YELLOW): $(YELLOW)$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)$(NO_COLOR)\n"
	@docker pull $(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)
	@printf "\n$(CYAN)Pulling Image $(YELLOW): $(YELLOW)$(REGISTRY)/$(REPOSITORY):$(TAG)$(NO_COLOR)\n"
	@docker pull $(REGISTRY)/$(REPOSITORY):$(TAG)

# `build` depends on `.build`, that rule is a bit particular as it actually
# represent a file on disc. It is used as placeholder to know if we need to
# redo the build. In a “regular” Makefile scenario, we would have source file
# instead.
build: banner $(DOCKERFILE) .build

# If `.build` exists and didn’t change (mtime), then do nothing, otherwise,
# executre the rule.
#
# `.build` depends on `.`, meaning that if anything (mtime) changes in the
# local  directory, the rule will be reexecuted (upon next `make` call).
#
# The `.build` rule, when finish creates the `.build` file. So next time
# make is called, nothing will happen unless something changed within the
# directory.
.build: . deps
	@printf "\n$(CYAN)Building image $(YELLOW): $(YELLOW)$(REGISTRY)/$(REPOSITORY):$(TAG)$(NO_COLOR)\n"
	@docker build --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
								--build-arg VERSION=$(TAG) \
								--build-arg VCS_URL=`git config --get remote.origin.url` \
								--build-arg VCS_REF=$(GIT_COMMIT) \
								--tag	$(REGISTRY)/$(REPOSITORY):$(TAG) \
								--file $(DOCKERFILE) .
	@docker inspect --format '{{.Id}}' $(REGISTRY)/$(REPOSITORY):$(TAG) > $(BUILD_ID)
ifeq "$(TAG)" "$(LATEST_TAG)"
	@docker tag $(TAG_OPTS) $(REGISTRY)/$(REPOSITORY):$(TAG) $(REGISTRY)/$(REPOSITORY):latest
endif

test: banner
	@printf "\n$(CYAN)Testing image $(YELLOW): $(YELLOW)$(REGISTRY)/$(REPOSITORY):$(TAG)$(NO_COLOR)\n"
	@test/run

docker_login:
	@printf "\n$(CYAN)Docker login $(YELLOW): $(YELLOW)https://index.docker.io/v1/$(NO_COLOR)\n"
	@bin/login

push: banner docker_login
	@for registry in $(PUSH_REGISTRIES); do \
		for tag in $(PUSH_TAGS); do \
			printf "\n$(CYAN)Pushing image $(YELLOW): $(YELLOW)$${registry}/$(REPOSITORY):$${tag}$(NO_COLOR)\n"; \
			docker tag $(TAG_OPTS) $(REGISTRY)/$(REPOSITORY):$(TAG) $${registry}/$(REPOSITORY):$${tag}; \
			docker push $${registry}/$(REPOSITORY):$${tag}; \
		done \
	done

serve_docs:
	@printf "\n$(CYAN)Render docs $(YELLOW): $(YELLOW)http://localhost:8000$(NO_COLOR)\n"
	@docker run --rm -p 8000:8000 -v $PWD:/work bluebeluga/mkdocs mkdocs serve

publish:
	@printf "\n$(CYAN)Publish docs $(YELLOW): $(YELLOW)http://blue-beluga.github.io/docker-alpine/latest$(NO_COLOR)\n"
ifneq ($(CI), $(CIRCLECI))
  @eval $(docker run bluebeluga/mkdocs circleci-cmd)
endif

clean: banner
	@printf "\n$(CYAN)Cleaning image $(YELLOW): $(YELLOW)$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG)$(NO_COLOR)\n"
	@rm -f versions/*/Dockerfile \
				 versions/*/.build_id \
				 versions/*/$(REPOSITORY)-*.tar
	@docker images -qa $(REPOSITORY):$(TAG) | xargs docker rmi -f
	@docker images -qa $(REPOSITORY):latest | xargs docker rmi -f

# Per-tag Dockerfile target. Look for Dockerfile or Dockerfile.tmpl in the root,
# and use it for $(TAG). We prioritize Dockerfile.tmpl over Dockerfile if
# both are present.
versions/$(TAG)/Dockerfile: Dockerfile.tmpl Dockerfile | $(TAG)
ifneq (,$(wildcard Dockerfile.tmpl))
	@bin/sigil -f Dockerfile.tmpl from=$(FROM_REGISTRY)/$(FROM_REPOSITORY):$(FROM_TAG) > $(DOCKERFILE)
else
	@cp Dockerfile > $(DOCKERFILE)
endif

# Pseudo targets for Dockerfile and Dockerfile.tmpl. They don't technically
# create anything, but each warn if the other file is missing (meaning both
# files are missing).
Dockerfile.tmpl:
ifneq (,$(wildcard Dockerfile.tmpl))
	$(warning You must create a 'Dockerfile.tmpl' or 'Dockerfile')
endif

Dockerfile:
ifneq (,$(wildcard Dockerfile))
	$(warning You must create a 'Dockerfile.tmpl' or 'Dockerfile')
endif

$(TAG):
	@mkdir -p versions/$(VERSION)

# We don't want `make` to get confused if a file named `all` should happen to
# exist, so we say that `all` is a `PHONY` target, i.e., a target that `make`
# should always try to update. We do that by making all a dependency of the
# special target `.PHONY`:
.PHONY : all banner deps build .build test docker_login push clean serve_docs publish

# Calling `make` will invoque the `all` rule.
.DEFAULT_GOAL := all
