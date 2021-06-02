
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

# Colors
grey = tput setaf 7; echo $1; tput sgr0;
red = tput setaf 1; echo $1; tput sgr0;
green = tput setaf 2; echo $1; tput sgr0;
yellow = tput setaf 3; echo $1; tput sgr0;
blue = tput setaf 4; echo $1; tput sgr0;
purple = tput setaf 5; echo $1; tput sgr0;
cyan = tput setaf 6; echo $1; tput sgr0;

default: help

.PHONY: help

help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init:	## Make terraform init
	@$(call yellow, "Init Terraform")
	@make symlinks
	@terraform init -reconfigure -backend-config=.terraform-config

plan:	## Make terraform plan
	@$(call cyan, "Plan Terraform")
	@terraform plan

apply:	## Make terraform apply
	@$(call green, "Apply Terraform")
	@terraform apply

destroy:  ## Plan terraform destroy
	@$(call red, "Plan Destroy Terraform")
	@terraform plan -destroy

mdestroy: ## Make terraform destroy
	@$(call red, "Destroy Terraform")
	@terraform plan -destroy
	@terraform apply -destroy

output:	## Make terraform output
	@$(call cyan, "Output Terraform")
	@terraform output

validate:	## Make terraform validate
	@$(call cyan, "Validate Terraform")
	@terraform validate

list:	## Make terraform state list
	@$(call cyan, "List Terraform state")
	@make symlinks
	@terraform state list

install:  ## Make tfenv install
	@$(call cyan, "Terraform Install")
	@tfenv install $(shell cat .terraform-version)

use:      ## Make tfenv use
	@$(call cyan, "Terraform Use version")
	@tfenv use $(shell cat .terraform-version)

version:  ## Show terraform version
	@$(call cyan, "Terraform version")
	@terraform version

cleanlinks:
	@$(call cyan, "Clean links")
	@if [ -L _backend.tf ] ; then unlink _backend.tf; fi
	@if [ -L _provider.tf ] ; then unlink _provider.tf; fi
	@if [ -L _main.tf ] ; then unlink _main.tf; fi
	@if [ -L _outputs.tf ] ; then unlink _outputs.tf; fi
	@if [ -L _variables.tf ] ; then unlink _variables.tf; fi
	@if [ -L _remote-states.tf ] ; then unlink _remote-states.tf; fi
	@if [ -L .terraform-version ] ; then unlink .terraform-version; fi
	@if [ -L init.tpl ] ; then unlink init.tpl; fi
	@if [ -L irsa.tf ] ; then unlink irsa.tf; fi

symlinks:
	@$(call cyan, "Make links")
	@if [ ! -L _backend.tf ] ; then ln -s ../../_terraform/backend.tf _backend.tf; fi
	@if [ ! -L _provider.tf ] ; then ln -s ../../_terraform/provider.tf _provider.tf; fi
	@if [ ! -L _main.tf ] ; then ln -s ../../_terraform/main.tf _main.tf; fi
	@if [ ! -L _outputs.tf ] ; then ln -s ../../_terraform/outputs.tf _outputs.tf; fi
	@if [ ! -L _variables.tf ] ; then ln -s ../../_terraform/variables.tf _variables.tf; fi
	@if [ ! -L _remote-states.tf ] && [ -f ../../_terraform/remote-states.tf ] ; then ln -s ../../_terraform/remote-states.tf _remote-states.tf; fi
	@if [ ! -L .terraform-version ] && [ ! -f .terraform-version ] ; then ln -s ../../_terraform/.terraform-version .terraform-version; fi
	@if [ ! -L init.tpl ] && [ -f ../../_terraform/init.tpl ] ; then ln -s ../../_terraform/init.tpl init.tpl;fi
	@if [ ! -L irsa.tf ] && [ -f ../../_terraform/irsa.tf ] ; then ln -s ../../_terraform/irsa.tf irsa.tf; fi
