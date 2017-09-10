#!/usr/bin/env bash

bun::util::init_pipe () 
{
  local pipe="${BUN_HOME}/.pipe"
  [[ -p "$pipe" ]] || mkfifo "$pipe"
  exec 9<> "$pipe"
  # Drain the pipe if needed.
  read -r -u 9 -t 0 -s && read -r -u 9 -t 0.1 -s
}

bun::util::clean_up ()
{
  popd &> /dev/null
}

bun::util::print_trace ()
{
 local result="$?"
 if [[ $result -eq 89 && read -r -u 9 -t 0 ]]; then
   read -r -u 9 -s msg && :
 fi
 msg="${msg:-Non-zero return value: $result}"
 printf 'Error occured: %s\n' "$msg"
 let w=${#BASH_LINENO[@]}
 for ((i=1; i<w; i++)); do
   printf '\tin %s() at %s:%d\n' \
      "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i-1]}" >&2
 done
}

