#!/usr/bin/env bash

fatal ()
{
  [[ $# -gt 0 ]] && printf '%s\n' "$1" 
  exit -1
}

throw ()
{
  printf '%s\n' "$1" 1>&9
  return 89 
}

use () 
{
  local plugin="$1"
  [[ -z "$plugin" ]] && fatal "Please give a plugin name to be loaded."
  [[ ${__PLUGINS[$plugin]} ]] && fatal "Unknown plugin: $plugin"
  # load plugin file
  . "${__PLUGINS[$plugin]}"
}

command_not_found_handle ()
{
  printf 'Command not found: %s\n' "$1" >&9 
  return 89 
}

