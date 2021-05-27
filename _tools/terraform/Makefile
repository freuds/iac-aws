default: help

export PATH := $(PATH):/usr/local/bin

SHELL:=/bin/bash -eu

# Colors
grey = tput setaf 7; echo $1; tput sgr0;
red = tput setaf 1; echo $1; tput sgr0;
green = tput setaf 2; echo $1; tput sgr0;
yellow = tput setaf 3; echo $1; tput sgr0;
blue = tput setaf 4; echo $1; tput sgr0;
purple = tput setaf 5; echo $1; tput sgr0;
cyan = tput setaf 6; echo $1; tput sgr0;

.PHONY: help

help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init:	## Make terraform init
	@$(call yellow, "Init Terraform")
	terraform init -reconfigure -backend-config=_backend.tfconfig ../terraform

plan:	## Make terraform plan
	@$(call cyan, "Plan Terraform")
	terraform plan -var-file=variables.tfvars ../terraform

apply:	## Make terraform apply
	@$(call green, "Apply Terraform")
	terraform apply -var-file=variables.tfvars ../terraform

destroy:## Make terraform destroy
	@$(call red, "Destroy Terraform")
	terraform destroy -var-file=variables.tfvars ../terraform

test:	## Make terraform test migration tool
	@make mklink
	@$(call purple, "Test migration tool")
	terraform 0.12checklist -var-file=variables.tfvars ../terraform
	@make clean

output:	## Make terraform output
	@make mklink
	@$(call cyan, "Output Terraform")
	terraform output
	@make clean

valid:	## Make terraform validate
	@$(call cyan, "Validate Terraform")
	terraform validate -check-variables=true -var-file=variables.tfvars ../terraform

list:	## Make terraform state list
	@$(call cyan, "List Terraform state")
	@make mklink
	terraform state list

fmt:	## Make terraform fmt
	@$(call cyan, "Terraform linting")
	terraform fmt ../terraform
	terraform fmt .

# install:	## Make tfenv install
# 	@$(call cyan, "Terraform Install")
# 	tfenv install

use:		## Make tfenv use
	@$(call cyan, "Terraform Install")
	tfenv use

clean:	## Make clean
	if [ -f backend.tf ] ; then unlink backend.tf; fi

mklink:
	if [ ! -L _backend.tf ] ; then ln -s ../terraform/_backend.tf _backend.tf; fi
	if [ ! -L _provider.tf ] ; then ln -s ../terraform/_provider.tf _provider.tf; fi
	if [ ! -L main.tf ] ; then ln -s ../terraform/main.tf main.tf; fi
	if [ ! -L outputs.tf ] ; then ln -s ../terraform/outputs.tf outputs.tf; fi
	if [ ! -L remote-states.tf ] ; then ln -s ../terraform/remote-states.tf remote-states.tf; fi
	if [ ! -L variables.tf ] ; then ln -s ../terraform/variables.tf variables.tf; fi
# exception for init.tpl & others tpl files

