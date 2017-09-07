#!/usr/bin/env bash

# function categories
export TEST=()
export BEFORE=()
export AFTER=()
export BEFORE_ALL=()
export AFTER_ALL=()
export SKIP=()

# Regex patterns for annotation processing 
__ANNOTATION="^[[:space:]]*#@[[:space:]]?(test|before|after|"
__ANNOTATION="${__ANNOTATION}skip|before-all|after-all)[[:space:]]*$"
__FUNCTION="^[[:space:]]*([A-z_][A-z0-9_?:!]*)[[:space:]]*\\("
__FUNCTION="${__FUNCTION}[[:space:]]*\\)[[:space:]]*{?[[:space:]]*(#.*)?$"
__COMMENT_OR_EMPTY='^[[:space:]]*(#.*)?$'

# TODO: filter out multiline strings
read_annotations() {
 local file="$1"
 local lines
 local context='none'

 # reset functions
 TEST=()
 BEFORE=()
 AFTER=()
 BEFORE_ALL=()
 AFTER_ALL=()
 SKIP=()
  
 readarray -t lines < "$file"
 
 for line in "${lines[@]}"; do  
   if [[ $line  =~ $__ANNOTATION ]]; then
     [[ "$context" != 'none' ]] && \
       __fatal "A function cannot have multiple annotations"
     context="${BASH_REMATCH[1]}"
     continue
   fi
   if [[ $line =~ $__FUNCTION && "$context" != 'none' ]]; then
     local fn=${BASH_REMATCH[1]} 
     local c=${context^^}
     c=${c/-/_}
     eval "${c}[\${#${c}[@]}]='${fn}'"
     context='none'
     continue
   fi
   if [[ ! $line =~ $__COMMENT_OR_EMPTY ]]; then
     context='none'
   fi
 done
}

third_func() {
 throw "This is an error here!" 
}
