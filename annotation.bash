#!/usr/bin/env bash

# Regex patterns for annotation processing
__ANNOTATION="^[[:space:]]*#@[[:space:]]?(test|before|after|"
__ANNOTATION="${__ANNOTATION}skip|before-all|after-all)[[:space:]]*$"
__FUNCTION='^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_?:!]*)[[:space:]]*\([[:space:]]*\)[[:space:]]*\{?[[:space:]]*(#.*)?$'
__COMMENT_OR_EMPTY='^[[:space:]]*(#.*)?$'

declare -A __METHODS=()

fatal_() {
  echo "$1"
}

# TODO: filter out multiline strings
read_annotations() {
 local file="$1"
 local lines
 declare -A context=()

 __METHODS=()
 while read -r line; do
   if [[ $line  =~ $__ANNOTATION ]]; then
     local current="${BASH_REMATCH[1]}"
     [[ -n ${context[$current]} ]] && \
       fatal_ "Should not have the same annotation twice: $current"
     context[$current]=1
     continue
   fi
   if [[ $line =~ $__FUNCTION && ${#context[@]} -ne 0 ]]; then
     local fn=${BASH_REMATCH[1]}
     [[ -n ${__METHODS[$fn]} ]] && \
       fatal_ "Should not have multiple function with the same name: $fn"
     __METHODS[$fn]="${!context[@]}"
     context=()
     continue
   fi
   if [[ ! $line =~ $__COMMENT_OR_EMPTY ]]; then
     context=()
   fi
 done < "$file"
}

read_annotations "$@"

for f in "${!__METHODS[@]}"; do
  printf '%s -> %s\n' "$f" "${__METHODS[$f]}"
done
