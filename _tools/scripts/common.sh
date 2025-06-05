#!/usr/bin/env bash
set -eo pipefail

# declare colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
BOLD="\e[1m"
UNDERLINE="\e[4m"
REVERSED="\e[7m"
BLACK="\e[30m"
# Reset all colors
RESET="\e[0m"

info() {
  printf "\r%s: ${CYAN}%s${RESET}\n" "$1" "$2"
}

msg() {
  printf "Service: ${MAGENTA}%s${RESET} is already at version: ${CYAN}%s${RESET}\n" "$1" "$2"
}

success() {
  printf "Service: ${MAGENTA}%s${RESET} is already at version: ${GREEN}%s${RESET}\n" "$1" "$2"
}

fail() {
  printf "\r${RED}%s${RESET}\n" "$1"
  exit 1
}

warm() {
  printf "\r${YELLOW}%s${RESET}\n" "$1"
}

divider() {
  printf "\r\033[0;1m========================================================================\033[0m\n"
}

pause_for_confirmation() {
  # shellcheck disable=SC2034
  read -rsp $'Press any key to continue (ctrl-c to quit):\n' -n1 key
}

cclear() {
  clear
}

interrupt_count=0
interrupt_handler() {
  ((interrupt_count += 1))

  echo ""
  if [[ $interrupt_count -eq 1 ]]; then
    fail "Really quit? Hit ctrl-c again to confirm."
  else
    echo "Goodbye!"
    exit
  fi
}

