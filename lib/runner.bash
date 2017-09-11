#!/usr/bin/env bash

bun::runner::run ()
{
  :
}

bun::runner::run_single_file ()
{
 local fn="$1"
 read_annotation "$fn"
 for method in "${!__METHODS[@]}"; do
   
 done
}

