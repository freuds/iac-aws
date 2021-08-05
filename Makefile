default: help

export PATH := $(PATH):/usr/local/bin

SHELL:=/bin/bash -eu

help:			## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

tf-init:   		## Create Organisation and workspaces on TF Cloud
	@_tools/scripts/init-tf-cloud.sh

fmt-global:   		## Apply terraform fmt recursively all .tf file
	@terraform fmt -recursive

tf-version-show: 	## Show current version in all .terraform-version files
	@_tools/scripts/uniformize-tf-version.sh -show

tf-version-fix:		## Apply the same version in all .terraform-version files
	@_tools/scripts/uniformize-tf-version.sh -fix