#
# Makefile
#
# Ping Service
# TODO: Need some sort of generic makefile for go services
#

REPO=ping
# Repository directory inside docker container
REPO_DIR=/go/src/github.com/newtonsystems/ping
# Filename of k8s deployment file inside 'local' devops folder
LOCAL_DEPLOYMENT_FILENAME=ping-deployment.yml

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
.PHONY: compile update-deps-featuretest update-deps-master install-deps-featuretest install-deps-master
update-deps-featuretest:
	rm -rf ./.glide
	@echo "$(INFO) Updating dependencies for featuretest environment"
	cp featuretest.lock glide.lock
	glide -y featuretest.yaml update --force
	cp glide.lock featuretest.lock

update-deps-master:
	rm -rf ./.glide
	@echo "$(INFO) Updating dependencies for $(BLUE)master$(RESET) environment"
	cp master.lock glide.lock
	glide -y master.yaml update --force
	cp glide.lock master.lock

install-deps-featuretest:
	@echo "$(INFO) Installing dependencies for featuretest environment"
	cp featuretest.lock glide.lock
	glide -y featuretest.yaml install
	cp glide.lock featuretest.lock

install-deps-master:
	@echo "$(INFO) Installing dependencies for $(BLUE)master$(RESET) environment"
	cp master.lock glide.lock
	glide -y master.yaml install
	cp glide.lock master.lock

update-install:
	@echo "$(INFO) Getting packages and building alpine go binary ..."
	@if [ "$(CURRENT_BRANCH)" != "master" && "$(CURRENT_BRANCH)" != "featuretest" ]; then \
		echo "$(INFO) for branch master " \
		make update-deps-master; \
		make install-deps-master; \
	else \
		echo "$(INFO) for branch $(CURRENT_BRANCH) " \
		make update-deps-$(CURRENT_BRANCH); \
		make install-deps-$(CURRENT_BRANCH); \
	fi


build-command:
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main ./server.go

compile:
	make update-install
	make build-command

# ------------------------------------------------------------------------------

#
# Main (Build binary)
#
.PHONY: build-bin

# TODO: Should speed this up with voluming vendor/
build-bin:              ##@build Cross compile the go binary executable
	@echo "$(INFO) Building a linux-alpine Go binary locally with a docker container $(BLUE)$(REPO):compile$(RESET)"
	docker build -t $(REPO):compile -f Dockerfile.build .
	docker run --rm -v "${PWD}":$(REPO_DIR) $(REPO):compile
	@echo ""

 #
 # Tests
 #
check:
	@echo "$(INFO) Running tests"
	go test -v .
