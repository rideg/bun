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

  # run each file one by one
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
 local fn="$1"
 read_annotation "$fn"
 for method in "${!__METHODS[@]}"; do
   export method
 done
}

# Regex patterns for annotation processing
__ANNOTATION='^[[:space:]]*#@[[:space:]]?'
__ANNOTATION=$__ANNOTATION'(test|before|after|skip|before-all|after-all)[[:space:]]*$'
__FUNCTION='^[[:space:]]*(function)?[[:space:]]*([a-zA-Z_][a-zA-Z0-9_?:!]*)'
__FUNCTION=$__FUNCTION'[[:space:]]*\([[:space:]]*\)[[:space:]]*\{?[[:space:]]*(#.*)?$'
__COMMENT_OR_EMPTY='^[[:space:]]*(#.*)?$'

bun::runner::process_file ()
{
 local file="$1"
 local lines
 declare -A context=()

 export __METHODS=()
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
     [[ -n ${__METHODS[$fn]} ]] && \
       fatal_ "Should not have multiple function with the same name: $fn"
     __METHODS[$fn]="${!context[*]}"
     context=()
     continue
   fi

   if [[ ! $line =~ $__COMMENT_OR_EMPTY ]]; then
     context=()
   fi
 done < "$file"
}

