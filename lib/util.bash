#!/usr/bin/env bash

bun::util::init_pipe ()
{
  local pipe_dir="$TMPDIR/bun/_$BASHPID$RANDROM$RANDOM"
  mkdir -p "$pipe_dir" &>/dev/null
  mkfifo "$pipe_dir/.pipe"
  exec 9<> "$pipe_dir/.pipe"
}

bun::util::clean_up ()
{
  exec 9<&-
  popd &> /dev/null
}

bun::util::print_trace ()
{
 local result="$?"
 if [[ $result -eq 89 ]]; then
   read -r -u 9 -t 0 && read -r -u 9 -s msg
 fi
 msg="${msg:-Non-zero return value: $result}"
 printf 'Error occured: %s\n' "$msg" >&2
 let w=${#BASH_LINENO[@]}
 for ((i=1; i<w; i++)); do
   printf '\tin %s() at %s:%d\n' \
      "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i-1]}" >&2
 done
}

