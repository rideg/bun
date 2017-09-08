use 'assert'
use 'spy'
use 'temp'
use 'sandbox'

#@ before-all
extra_init() {
  :
}

#@ after-all 
extra_tear_down() {
  :
}

#@ before
init() {
  :
}

#@ after
tear_down() {
  mock tool
  when tool arg2 arg3 arg4 \
      --then print value
      --and return 0
  when tool arg4 arg4 \
      --then execute command

  run command

  assert value "message"
  assert_output -p
  verify tool --time 3 --called-with 'arg1 arg2 arg3'
  verify tool --zero-invocation 
  fail "Error message"
}

#@ skip
#@ test
function this_is_a_test_with_something() {
  :
}

#@ test

this_is_a_test_with_something2() {
  :
}

#@ skip
this_is_another_test_which_will_be_skipped() {
:
}

#@ skip
this_skip2() { #skipped
 :
 }



 string=<<EOF
 this is a multi line string
 and continues

 #@ test
 this_is_a_test() {
   ttt
EOF


