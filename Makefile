default: help

export PATH := $(PATH):/usr/local/bin

SHELL:=/bin/bash -eu

help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init-tfcloud:   ## Create Organisation and workspaces on TF Cloud
	@_tools/scripts/init-tf-cloud.sh

fmt-global:   ## formate tous les .tf file
	@terraform fmt -recursive

show-terraform-version:
	@find . -name ".terraform-version" -exec cat {} \;
	
fix-terraform-version:
	@_tools/scripts/uniformize-tf-version.sh