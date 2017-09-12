#!/usr/bin/env bash

bun::runner::run ()
{
  local dir=$1
  shift	

  local locations=()
  for arg in "$@"; do
    case "$arg" in
      -r|--recursive) recursive=0;;
      *) locations[${#locations}]="$dir/$arg";;
    esac
  done

  [[ ${#locations[@]} -eq 0 ]] && locations[0]="$dir"
  
  local files=() 
  for location in "${locations[@]}"; do
    if [[ -f "$location" && -r "$location" ]]; then
	    files[${#files[@]}]="$location" 
    fi

    if [[ -d "$location" ]]; then
      bun::runner::traverse_directory "$location" "${recursive+recursive}"
      files=("${files[@]}" "${__[@]}")
    fi
  done

  [[ ${#files[@]} -eq 0 ]] && fatal "No files to run!"
 
  declare -i all=0 
  declare -i failed=0
  for file in "${files[@]}"; do
    $(bun::runner::run_file "$file") 
  done
}

bun::runner::traverse_directory ()
{
  local dir="$1"
  local recursive="$2"
  declare -a files=()

  for file in "$dir"/*; do
    if [[ -f "$file" && -r "$file" && "$file" =~ ^.*test\.(ba)?sh$ ]]; then
      files[${#files[@]}]="$file"
    fi 

    if [[ -n ${recursive+recursive} && -d "$file" ]]; then
       bun::runner::traverse_directory "$file" "$recursive"
       files=("${files[@]}" "${__[@]}") 
    fi
  done

  __=("${files[@]}")
}

bun::runner::run_file ()
{
 local file="$1"
 bun::runner:process_file "$file"
 local methods=("${__[@]}")
 for method in "${methods[@]}"; do
   export method
 done
}

# Regex patterns for annotation processing
__ANNOTATION='^[[:space:]]*#@[[:space:]]?(test|before|after|skip'
__ANNOTATION=$__ANNOTATION'[[:space:]]*$|before-all|after-all)'
__FUNCTION='^[[:space:]]*(function)?[[:space:]]*([a-zA-Z_][a-zA-Z0-9_?:!]*)[[:spa'
__FUNCTION=$__FUNCTION'ce:]]*\([[:space:]]*\)[[:space:]]*\{?[[:space:]]*(#.*)?$'
__COMMENT_OR_EMPTY='^[[:space:]]*(#.*)?$'

bun::runner::process_file ()
{
 local file="$1"
 local lines
 declare -A context=()

 local methods=()
 while read -r line; do
   if [[ $line  =~ $__ANNOTATION ]]; then
     local current="${BASH_REMATCH[1]}"
     [[ -n ${context[$current]} ]] && \
       fatal_ "Should not have the same annotation twice: $current"
     context[$current]=1
     continue
   fi

   if [[ $line =~ $__FUNCTION && ${#context[@]} -ne 0 ]]; then
     local fn=${BASH_REMATCH[2]}
     [[ -n ${methods[$fn]} ]] && \
       fatal_ "Should not have multiple function with the same name: $fn"
     methods[$fn]="${!context[*]}"
     context=()
     continue
   fi

   if [[ ! $line =~ $__COMMENT_OR_EMPTY ]]; then
     context=()
   fi
 done < "$file"
 __=("${methods[@]}")
}

