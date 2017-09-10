#!/usr/bin/env bash

__warning() {
  :
}

__run_single_file() {
 local fn="$1"
 read_annotation "$fn"
 for method in "${!__METHODS[@]}"; do
   
 done
}




