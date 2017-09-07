#!/usr/bin/env bash
set -Ee

__fatal() {
 echo "$1"
 exit -1
}

__warning() {
  :
}

_init_pipe() {
 [[ -p ".pipe" ]] || mkfifo ".pipe"
  exec 9<> ".pipe"
}

use() {
 local plugin="$1"
 [[ -z "$plugin" ]] && __fatal "Please give a plugin name to be loaded."
 [[ ${__PLUGINS[$plugin]} ]] && fatal_ "Unknown plugin: $plugin"
 # load plugin file
 . "${__PLUGINS[$plugin]}"
}

__run_single_file() {
 local fn="$1"
 read_annotation "$fn"
 [[ ${#TEST[@]} == 0 ]] && __warning "Skipping file: $fn (no tests can be found)."
 . "$fn"
 # TODO: cleanup functions if we mistakenly parsed them as
   
}

throw() {
  printf '%s\n' "$1" 1>&9
  return 89 
}

print_trace() {
 local result="$?"
 if [[ $result -eq 89 ]]; then
   read -r -u 9 -s -t 0.1 msg && :
 fi
 msg="${msg:-Non-zero return value: $result}"
 printf 'Error occured: %s\n' "$msg"
 let w=${#BASH_LINENO[@]}
 for ((i=1; i<w; i++)); do
   printf '\t at %s::%s() line %d\n' \
      "${BASH_SOURCE[$i]}" "${FUNCNAME[$i]}" "${BASH_LINENO[$i-1]}"
 done
}

command_not_found_handle() {
  printf 'Command not found: %s\n' "$1" 1>&9 
  return 89 
}

clean() {
 rm -rf ./.pipe > /dev/null
}

trap print_trace ERR
trap clean EXIT
_init_pipe

