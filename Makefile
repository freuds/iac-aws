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

help:	## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

tfinit:   ## Create Organisation and workspaces on TF Cloud
	@_tools/scripts/tfcloud.sh
