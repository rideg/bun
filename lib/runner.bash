#!/usr/bin/env bash

bun::runner::run ()
{
  # parse arguments
  # collect files 
  # go trough locations (separate files from directories) 
  # go trough directories and collect *test.sh & *test.bash files
  # if recursive and find directories add them back
  # repeat
  # run each file one by one
}

bun::runner::run_single_file ()
{
 local fn="$1"
 read_annotation "$fn"
 for method in "${!__METHODS[@]}"; do
   
 done
}

