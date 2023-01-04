.DEFAULT_GOAL := help

CURRENTTAG:=$(shell git describe --tags --abbrev=0)
NEWTAG ?= $(shell bash -c 'read -p "Please provide a new tag (currnet tag - ${CURRENTTAG}): " newtag; echo $$newtag')
GOFLAGS=-mod=mod
GOPRIVATE=github.com/threeport/*

#help: @ List available tasks
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-17s\033[0m - %s\n", $$1, $$2}'

#clean: @ Cleanup
clean:
	@sudo rm -rf vendor/

#test: @ Run tests
test:
	@go generate
	@export GOPRIVATE=$(GOPRIVATE); export GOFLAGS=$(GOFLAGS); go test ./...

#build: @ Build
build:
	@go generate
	@export GOPRIVATE=$(GOPRIVATE); export GOFLAGS=$(GOFLAGS); go build ./...

#get: @ Download and install dependency packages
get:
	@export GOPRIVATE=$(GOPRIVATE); export GOFLAGS=$(GOFLAGS); go get . ; go mod tidy

#release: @ Create and push a new tag
release: clean
	$(eval NT=$(NEWTAG))
	@echo -n "Are you sure to create and push ${NT} tag? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo ${NT} > ./version.txt
	@git add -A
	@git commit -a -s -m "Cut ${NT} release"
	@git tag ${NT}
	@git push origin ${NT}
	@git push
	@echo "Done."

#update: @ Update dependency packages to latest versions
update: clean
	@export GOPRIVATE=$(GOPRIVATE); export GOFLAGS=$(GOFLAGS); go get -u; go mod tidy

#version: @ Print current version(tag)
version:
	@echo $(shell git describe --tags --abbrev=0)
