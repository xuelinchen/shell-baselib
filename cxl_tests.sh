#!/bin/bash

######################################
# 
# 脚本名称: cxl_tests
#
# 目的:
#    1、test
#
# 注意事项：
#    ./cxl_tests.sh
#
# 作者: chenxuelin@emicnet.com
# 
######################################

. cxl_log
. cxl_utils

totalCase=1
failCase=0
successCase=1
pretty_title "TESTS BEGIN" && status=0 || status=1
if [ $status != 0 ]; then echo "无法完成测试"; exit 1; fi

cxl_log_file="cxl.log"
cxl_log "it is log" "info" && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'cxl_log' failed"; fi
let "totalCase++"

print_log "this is log and print in the screen" "info" && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'print_log' failed"; fi
let "totalCase++"

make_tmp_file ".tmp" && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'make_tmp_file' failed"; fi
let "totalCase++"

cxl_indexOf "no" "one two three" && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'cxl_indexOf' failed"; fi
let "totalCase++"

command_exist "nols" && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'command_exist' failed"; fi
let "totalCase++"

province=`cxl_get_province "shaanxi"` && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'cxl_get_province' failed"; fi
let "totalCase++"

province=`cxl_get_areacode "guangxi"` && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'cxl_get_areacode' failed"; fi
let "totalCase++"
#echo $province

json=`parse_to_json "guangxi=ddd&dss=value"` && status=0 || status=1
if [ $status = 0 ]; then let "successCase++" ; else let "failCase++"; cxl_echo_fail "function 'parse_to_json' failed"; fi
let "totalCase++"
echo $json

pretty_title "TESTS REPORT"

cxl_echo_success "SUCCESS CASE:$successCase"
cxl_echo_fail "FAIL CASE:$failCase"
cxl_echo_warn "TOAOL CASE:$totalCase"

pretty_title "TESTS END"