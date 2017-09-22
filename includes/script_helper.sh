#!/bin/bash

# Logs a message to stdout, prefixing the message with the script
# name.
#
# Parameters: same as the `echo` shell built-in
# Preconditions: none

function print_stack() {

  local i

  local stack_size=${#FUNCNAME[@]}

  log "Stack trace (most recent call first):"

  # to avoid noise we start with 1, to skip the current function

  for (( i=1; i<$stack_size ; i++ )); do

    local func="${FUNCNAME[$i]}"

    [[ -z "$func" ]] && func='MAIN'

    local line="${BASH_LINENO[(( i - 1 ))]}"

    local src="${BASH_SOURCE[$i]}"

    [[ -z "$src" ]] && src='UNKNOWN'



    log "  $i: File '$src', line $line, function '$func'"

  done

}
function log() {
  echo "[$(basename $0)-$(date '+%H:%M:%S')] $@"

}

# Try to execute a command. If the command returns success, this
# function returns 0. Otherwise, the script is aborted with the status
# code of the failed command.
#
# Parameters: the command to be executed, with its arguments as separate shell parameters
# Preconditions: none
function tryexec () {
  "$@"
  local retval=$?
  [[ $retval -eq 0 ]] && return 0

  log 'A command has failed:'
  log "  $@"
  log "Value returned: ${retval}"
  print_stack
  exit $retval
}
rootcheck () {
    if [ $(id -u) != "0" ]
    then
        sudo "$0" "$@" 
        log "please run as root"
        exit $?
    fi
}

