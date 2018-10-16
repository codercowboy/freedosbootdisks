#!/bin/bash

#################################################################################
#
# testhexlib.sh - Test suite for hexlib.sh
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   project's github: https://github.com/codercowboy/freedosbootdisks
#   more info: http://www.codercowboy.com
#
#################################################################################
#
# UPDATES:
# 
# 2018/10/15
# - Initial version
#
#################################################################################
#
# Copyright (c) 2018, Coder Cowboy, LLC. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#  
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied.
#
#################################################################################

DEBUG_HEXLIB="true"

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"

source "${SCRIPT_HOME}/hexlib.sh"

TEST_FILE="${SCRIPT_HOME}/test.tmp"
debug_log "TEST_FILE: ${TEST_FILE}"
if [ -f "${TEST_FILE}" ]; then
	rm "${TEST_FILE}"
fi
echo -n "ABCD" > "${TEST_FILE}"

RESULT=$(extract_string_from_file 0 4 "${TEST_FILE}")
verify_test "Test 1.a" "ABCD" "${RESULT}"

RESULT=$(extract_string_from_file 1 2 "${TEST_FILE}")
verify_test "Test 1.b" "BC" "${RESULT}"

RESULT=$(extract_string_from_file 3 1 "${TEST_FILE}")
verify_test "Test 1.c" "D" "${RESULT}"

RESULT=$(extract_string_from_file 32 40 "${TEST_FILE}")
verify_test "Test 1.d" "" "${RESULT}"

RESULT=$(reverse_hex_order "0x00ABCD03")
verify_test "Test 2.a" "0x03CDAB00" "${RESULT}"

RESULT=$(reverse_hex_order "0x00AB")
verify_test "Test 2.b" "0xAB00" "${RESULT}"

RESULT=$(reverse_hex_order "0xAB")
verify_test "Test 2.c" "0xAB" "${RESULT}"

RESULT=$(convert_hex_to_number "0x00")
verify_test "Test 3.a" "0" "${RESULT}"	

RESULT=$(convert_hex_to_number "0x01")
verify_test "Test 3.b" "1" "${RESULT}"

RESULT=$(convert_hex_to_number "0x13")
verify_test "Test 3.c" "19" "${RESULT}"

RESULT=$(convert_hex_to_number "0x0F")
verify_test "Test 3.d" "15" "${RESULT}"

RESULT=$(convert_hex_to_number "0x0A")
verify_test "Test 3.e" "10" "${RESULT}"

RESULT=$(convert_hex_to_number "0x0001")
verify_test "Test 3.f" "1" "${RESULT}"

RESULT=$(convert_hex_to_number "0xFF00FF")
verify_test "Test 3.g" "16711935" "${RESULT}"

RESULT=$(convert_hex_to_ascii_string "0x4A61736F6E")
verify_test "Test 4.a" "Jason" "${RESULT}"

RESULT=$(convert_number_to_hex 0)
verify_test "Test 5.a" "0x00" "${RESULT}"

RESULT=$(convert_number_to_hex 1)
verify_test "Test 5.b" "0x01" "${RESULT}"

RESULT=$(convert_number_to_hex 15)
verify_test "Test 5.c" "0x0F" "${RESULT}"

RESULT=$(convert_number_to_hex 255)
verify_test "Test 5.d" "0xFF" "${RESULT}"

RESULT=$(convert_number_to_hex 123456789)
verify_test "Test 5.e" "0x075BCD15" "${RESULT}"

RESULT=$(convert_ascii_string_to_hex "Jason")
verify_test "Test 6.a" "0x4A61736F6E" "${RESULT}"

# test file before here was "ABCD"

# lowercase to "abcd"
replace_bytes 0 "0x61626364" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 7.a" "abcd" "${RESULT}"

# write "A" in first byte
replace_bytes 0 "0x41" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 7.b" "Abcd" "${RESULT}"

# write "D" in fourth byte
replace_bytes 3 "0x44" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 7.c" "AbcD" "${RESULT}"

# write "EFG" at end
replace_bytes 4 "0x454647" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 7.d" "AbcDEFG" "${RESULT}"

echo -n "ABCD" > "${TEST_FILE}"

# write "a" in first byte
replace_string_in_file 0 "a" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 8.a" "aBCD" "${RESULT}"

# write "d" in fourth byte
replace_string_in_file 3 "d" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 8.b" "aBCd" "${RESULT}"

# write "XY" in second/third byte
replace_string_in_file 1 "XY" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 8.c" "aXYd" "${RESULT}"

# write "ABCDEFGHIJK" over file
replace_string_in_file 0 "ABCDEFGHIJK" "${TEST_FILE}"
RESULT=`cat ${TEST_FILE}`
verify_test "Test 8.d" "ABCDEFGHIJK" "${RESULT}"

# write 15 to file
rm "${TEST_FILE}"
HEX_NUMBER=$(convert_number_to_hex 15)
replace_bytes 0 "${HEX_NUMBER}" "${TEST_FILE}"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 9.a" "15" "${RESULT}"

#write 1 to file
rm "${TEST_FILE}"
HEX_NUMBER=$(convert_number_to_hex 1)
replace_bytes 0 "${HEX_NUMBER}" "${TEST_FILE}"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 9.b" "1" "${RESULT}"

#write 0 to file
rm "${TEST_FILE}"
HEX_NUMBER=$(convert_number_to_hex 0)
replace_bytes 0 "${HEX_NUMBER}" "${TEST_FILE}"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 9.c" "0" "${RESULT}"

# write 255 to file twice (which will read out as 65535)
rm "${TEST_FILE}"
HEX_NUMBER=$(convert_number_to_hex 255)
replace_bytes 0 "${HEX_NUMBER}" "${TEST_FILE}"
replace_bytes 1 "${HEX_NUMBER}" "${TEST_FILE}"
RESULT=$(extract_number_from_file 0 2 "${TEST_FILE}")
verify_test "Test 9.d" "65535" "${RESULT}"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 9.e" "255" "${RESULT}"
RESULT=$(extract_number_from_file 1 1 "${TEST_FILE}")
verify_test "Test 9.f" "255" "${RESULT}"

rm "${TEST_FILE}"
replace_bytes 0 "0x00000000" "${TEST_FILE}"
RESULT=$(extract_number_from_file 1 4 "${TEST_FILE}")
verify_test "Test 9.g" "0" "${RESULT}"

replace_number_in_file 1 255 "${TEST_FILE}"
echo "Current file contents: `extract_bytes 0 4 "${TEST_FILE}"`"
RESULT=$(extract_number_from_file 1 1 "${TEST_FILE}")
verify_test "Test 10.a" "255" "${RESULT}"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 10.b" "0" "${RESULT}"
RESULT=$(extract_number_from_file 2 1 "${TEST_FILE}")
verify_test "Test 10.c" "0" "${RESULT}"
RESULT=$(extract_number_from_file 3 1 "${TEST_FILE}")
verify_test "Test 10.d" "0" "${RESULT}"
RESULT=$(extract_number_from_file 1 3 "${TEST_FILE}")
verify_test "Test 10.e" "255" "${RESULT}"

rm "${TEST_FILE}"
replace_bytes 0 "0x00000000" "${TEST_FILE}"
RESULT=$(extract_number_from_file 1 4 "${TEST_FILE}")
verify_test "Test 10.f" "0" "${RESULT}"

replace_number_in_file 1 65535 "${TEST_FILE}"
echo "Current file contents: `extract_bytes 0 4 "${TEST_FILE}"`"
RESULT=$(extract_number_from_file 0 1 "${TEST_FILE}")
verify_test "Test 10.g" "0" "${RESULT}"
RESULT=$(extract_number_from_file 1 1 "${TEST_FILE}")
verify_test "Test 10.h" "255" "${RESULT}"
RESULT=$(extract_number_from_file 2 1 "${TEST_FILE}")
verify_test "Test 10.i" "255" "${RESULT}"
RESULT=$(extract_number_from_file 3 1 "${TEST_FILE}")
verify_test "Test 10.j" "0" "${RESULT}"	
RESULT=$(extract_number_from_file 1 2 "${TEST_FILE}")
verify_test "Test 10.k" "65535" "${RESULT}"
RESULT=$(extract_number_from_file 100 20 "${TEST_FILE}")
verify_test "Test 10.l" "0" "${RESULT}"

#decimal 312 is hex 0x0138
rm "${TEST_FILE}"
replace_bytes 0 "0x00000000" "${TEST_FILE}"
RESULT=$(extract_number_from_file 1 4 "${TEST_FILE}")
verify_test "Test 10.m" "0" "${RESULT}"
replace_number_in_file 1 312 "${TEST_FILE}"
echo "Current file contents: `extract_bytes 0 4 "${TEST_FILE}"`"
RESULT=$(extract_number_from_file 1 2 "${TEST_FILE}")
verify_test "Test 10.n" "312" "${RESULT}"

rm "${TEST_FILE}"

echo ""
echo "All Tests Passed!"

exit 0