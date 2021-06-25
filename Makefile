default: help

export PATH := $(PATH):/usr/local/bin

SHELL:=/bin/bash -eu

help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

init-tfcloud:   ## Create Organisation and workspaces on TF Cloud
	@_tools/scripts/tfcloud.sh

fmt-global:   ## formate tous les .tf file
	@terraform fmt -recursive