#
# Makefile
#
# Ping Service
# TODO: Need some sort of generic makefile for go services
#

REPO=ping
LOCAL_DEPLOYMENT_FILENAME=ping-deployment.yml
GO_MAIN=./server.go
GO_PORT=50000


# Repository directory inside docker container
REPO_DIR=/go/src/github.com/newtonsystems/ping
# Filename of k8s deployment file inside 'local' devops folder


NEWTON_DIR=/Users/danvir/Masterbox/sideprojects/github/newtonsystems/
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
CURRENT_RELEASE_VERSION=0.0.1

TIMESTAMP=tmp-$(shell date +%s )

#
# Help for Makefile & Colorised Messages
#
# Powered by https://gist.github.com/prwhite/8168133
GREEN  := $(shell tput -Txterm setaf 2)
RED    := $(shell tput -Txterm setaf 1)
BLUE   := $(shell tput -Txterm setaf 4)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

INFO=$(GREEN)[INFO] $(RESET)
STAGE=$(BLUE)[INFO] $(RESET)
ERROR=$(RED)[ERROR] $(RESET)
WARN=$(YELLOW)[WARN] $(RESET)

#
# Help Command
#

# Add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (32 - length $$_->[0]); \
    print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

.PHONY: help

help:                        ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

# ------------------------------------------------------------------------------
.PHONY: update master build-exec

update:       ##@build Updates dependencies for your go application
	mkubectl.sh --update-deps

install:      ##@build Install dependencies for your go application
	mkubectl.sh --install-deps

build-exec:   ##@compile Builds executable cross compiled for alpine docker
	@echo "$(INFO) Building a linux-alpine Go binary locally with a docker container $(BLUE)$(REPO):compile$(RESET)"
	docker build -t $(REPO):compile -f Dockerfile.build .
	docker run --rm -v "${PWD}":$(REPO_DIR) $(REPO):compile


# ------------------------------------------------------------------------------
# CircleCI support
.PHONY: check

check:        @circleci Needed for running circleci tests
	@echo "$(INFO) Running tests"
	go test -v .

# ------------------------------------------------------------------------------
# Non docker local development (can be useful for super fast local/debugging)
#.PHONY: run-conn-local

#run-conn:
#	go run ${GO_MAIN} --conn.local

# ------------------------------------------------------------------------------
# Minikube (Normal Development)
.PHONY: run-dev swap-local-hot-reload swap-latest swap-latest-release

run-dev:                ##@dev Alias for swap-local-hot-reload
	swap-hot-local

swap-hot-local:         ##@dev Swaps $(REPO) deployment in minikube (You must make sure you are running i.e. infra-minikube.sh --create)
	mkubectl.sh --hot-reload-deployment ${REPO} ${LOCAL_DEPLOYMENT_FILENAME} ${GO_MAIN} ${GO_PORT}

swap-latest:            ##@dev Swaps $(REPO) deployment in minikube with the latest image for branch from dockerhub (You must make sure you are running i.e. infra-minikube.sh --create)
	mkubectl.sh --swap-deployment-with-latest-image

swap-latest-release:    ##@dev Swaps $(REPO) deployment in minikube with the latest release image for from dockerhub (You must make sure you are running i.e. infra-minikube.sh --create)
	mkubectl.sh --swap-deployment-with-latest-image
