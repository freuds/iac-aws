
export PATH := $(PATH):/usr/local/bin

SHELL:=/bin/bash -eu

TAG ?= latest
NAMESPACE ?= default
VERSION ?= 0.1.0
#VERSION ?= $$(git rev-parse HEAD)
SERVICE_NAME ?= hugo

# Get environment depends of current path
ENVIRONMENT = $(shell basename $(realpath $(PWD)))
# realpath of Makefile
WORKDIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPOSITORY ?= ${WORKDIR}charts
CHART ?= ${WORKDIR}charts/${SERVICE_NAME}
ARGUMENTS ?=

default: help

.PHONY: help
help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: init
init:	## Make terraform init
	@make symlinks
	@terraform init -reconfigure -backend-config=.terraform-config

.PHONY: plan
plan:	## Make terraform plan
	@terraform plan

.PHONY: apply
apply:	## Make terraform apply
	@terraform apply

apply-force: ## Make terraform apply --auto-approve
	@terraform apply --auto-approve

destroy:  ## Plan terraform destroy
	@terraform plan -destroy

mdestroy: ## Make terraform destroy
	@terraform plan -destroy
	@terraform apply -destroy

.PHONY: output
output:	## Make terraform output
	@terraform output

validate:	## Make terraform validate
	@terraform validate

list:	## Make terraform state list
	@make symlinks
	@terraform state list

providers:	## Make terraform state list
	@terraform providers

# install:  ## Make tfenv install
# 	@tfenv install $(shell cat .terraform-version)

# use:      ## Make tfenv use
# 	@tfenv use $(shell cat .terraform-version)

version:  ## Show terraform version
	@terraform version

cleanlinks:
	@if [ -L _backend.tf ] ; then unlink _backend.tf; fi
	@if [ -L _provider.tf ] ; then unlink _provider.tf; fi
	@if [ -L _main.tf ] ; then unlink _main.tf; fi
	@if [ -L _outputs.tf ] ; then unlink _outputs.tf; fi
	@if [ -L _variables.tf ] ; then unlink _variables.tf; fi
	@if [ -L _remote-states.tf ] ; then unlink _remote-states.tf; fi
	@if [ -L .terraform-version ] ; then unlink .terraform-version; fi
# @if [ -L init.tpl ] ; then unlink init.tpl; fi
	@if [ -L irsa.tf ] ; then unlink irsa.tf; fi

symlinks:
	@if [ ! -L _backend.tf ] ; then ln -s ../../_terraform/backend.tf _backend.tf; fi
	@if [ ! -L _provider.tf ] ; then ln -s ../../_terraform/provider.tf _provider.tf; fi
	@if [ ! -L _main.tf ] ; then ln -s ../../_terraform/main.tf _main.tf; fi
	@if [ ! -L _outputs.tf ] ; then ln -s ../../_terraform/outputs.tf _outputs.tf; fi
	@if [ ! -L _variables.tf ] ; then ln -s ../../_terraform/variables.tf _variables.tf; fi
	@if [ ! -L _remote-states.tf ] && [ -f ../../_terraform/remote-states.tf ] ; then ln -s ../../_terraform/remote-states.tf _remote-states.tf; fi
	@if [ ! -L .terraform-version ] && [ ! -f .terraform-version ] ; then ln -s ../../_terraform/.terraform-version .terraform-version; fi
# @if [ ! -L init.tpl ] && [ -f ../../_terraform/init.tpl ] ; then ln -s ../../_terraform/init.tpl init.tpl;fi
	@if [ ! -L irsa.tf ] && [ -f ../../_terraform/irsa.tf ] ; then ln -s ../../_terraform/irsa.tf irsa.tf; fi
