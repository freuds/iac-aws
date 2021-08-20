default: help

export PATH := $(PATH):/usr/local/bin
SHELL:=/bin/bash -eu

# SERVICES = baseline build vpc myapp
KEYPAIR_NAME = iac-aws-key
SERVICES = build vpc myapp
ENV ?= qa
REGION ?= eu-west-1

help:			## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init-tfc:   		## Create Organisation and workspaces on TF Cloud
	@_tools/scripts/init-tf-cloud.sh

fmt-global:   		## Apply terraform fmt recursively all .tf file
	@terraform fmt -recursive

tf-version-show: 	## Show current version in all .terraform-version files
	@_tools/scripts/uniformize-tf-version.sh -show

tf-version-fix:		## Apply the same version in all .terraform-version files
	@_tools/scripts/uniformize-tf-version.sh -fix

.PHONY: install
install: $(SERVICES) ## Install all services in specific order

.PHONY: ${SERVICES}
${SERVICES}:
	@CURDIR=$(shell pwd)
	cd $@/$(ENV)/$(REGION) ; make init
# make apply-force
	cd $(CURDIR)

keypair-create: ## Create a new Key Pair in defined AWS Region
	@aws ec2 create-key-pair --key-name $(KEYPAIR_NAME) --query 'KeyMaterial' --output text > $(HOME)/.ssh/$(KEYPAIR_NAME).pem --region $(REGION)
	@chmod 0600 $(HOME)/.ssh/$(KEYPAIR_NAME).pem

keypair-delete: ## Delete the Key Pair in defined AWS Region
	@aws ec2 delete-key-pair --key-name $(KEYPAIR_NAME) --region $(REGION)
	@rm -f $(HOME)/.ssh/$(KEYPAIR_NAME).pem

keypair-display: ## Display existing Key Pair in defined AWS Region
	@aws ec2 describe-key-pairs --key-name $(KEYPAIR_NAME) --region $(REGION)