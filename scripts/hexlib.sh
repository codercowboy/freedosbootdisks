#!/bin/bash

#################################################################################
#
# hexlib.sh - bash utilities to work with extracting / writing binary data
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

debug_log() {
	if [ "true" = "${DEBUG_HEXLIB}" ]; then
		echo "DEBUG: ${1}" > /dev/stderr
	fi
}

# verifies test results
# arg 1: test name
# arg 2: expected result
# arg 3: actual result
# returns: nothing
verify_test() {
	if [ ! "${2}" = "${3}" ]; then
		echo "TEST FAILURE: ${1}, expected: '${2}', actual: '${3}'"
		exit 1
	else
		echo "Test SUCCESS: ${1}, expected: '${2}', actual: '${3}'"
	fi 
}

# reverses a hex string such as "0x4241" to "0x4142"
# arg 1: string to reverse
# returns: reversed string
reverse_hex_order() {
	debug_log "reverse_hex_order input: ${1}"
	# input is something like "0x434241", strip the "0x" from front
	INPUT=`echo -n "${1}" | sed 's/0x//'`	
	#debug_log "reverse_hex_order input with '0x' stripped from front: ${INPUT}"
	# inptu is now 434241
	# put a space between each pair so we have 43 42 41
	INPUT=`echo -n "${INPUT}" | sed 's/\(..\)/\1 /g'`
	#debug_log "reverse_hex_order input with space between each pair: ${INPUT}"
	# input is now something like 43 42 41, put them together in reverse order
	OUTPUT=""
	for PAIR in ${INPUT}; do
		#debug_log "reverse_hex_order current pair: '${PAIR}'"
		PAIR=`echo -n "${PAIR}" | sed 's/ //g'` #remove spaces from end of pair
		if [ ! -z "${PAIR}" ]; then #only prepend non-empty pairs
			OUTPUT="${PAIR}${OUTPUT}"
		fi
	done
	# now output is something like 434241, add "0x before it"
	OUTPUT=`echo -n "0x${OUTPUT}"`
	# now output is 0x434241
	debug_log "reverse_hex_order result: ${OUTPUT}"
	echo -n "${OUTPUT}"
}

# extracts bytes from file from specified offset in a hex string format
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: count of bytes to read in decimal ie "4"
# arg 3: file to extract from
# returns: bytes in hex format ie "0xABCD"
extract_bytes() {
	debug_log "extract_bytes offset: ${1}, byte count: ${2}, file: ${3}"
	# from: https://unix.stackexchange.com/questions/155085/fetching-individual-bytes-from-a-binary-file-into-a-variable-with-bash
	# and: https://stackoverflow.com/questions/6292645/convert-binary-data-to-hex-in-shell-script
	OUTPUT="0x`dd if="${3}" count=${2} bs=1 skip=${1} conv=notrunc | hexdump -e '"%X"'`" 
	OUTPUT=$(fix_hex_padding "${OUTPUT}")
	# extracted bytes are backwards hex like 434241 when we want 414243
	OUTPUT=`reverse_hex_order "${OUTPUT}"`
	# extracted bytes are now 0x414243
	debug_log "extract_bytes extracted: ${OUTPUT}"
	echo -n "${OUTPUT}"
}

# replace bytes to file at specified offset
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: bytes to write in hex string format ie "0xABCD"
# arg 3: file to replace bytes in
# returns: nothing
replace_bytes() {
	debug_log "replace_bytes offset: ${1}, bytes to write: ${2}, file: ${3}"
	# from: https://stackoverflow.com/questions/4783657/cli-write-byte-at-address-hexedit-modify-binary-from-the-command-line
	# input is something like "0x434241", strip the "0x" from front
	INPUT=`echo -n "${2}" | sed 's/0x//'`	
	# byte count to write is length of string / 2
	BYTE_COUNT=`expr ${#INPUT} / 2`
	# printf needs a format of \x41\x42 with "\x" between each hex pair to print hex as ascii
	# put the "\x" in the string
	INPUT=`echo -n "${INPUT}" | sed 's/\(..\)/\\\\x\1/g'`
	debug_log "replace_bytes final input: ${INPUT}, byte count: ${BYTE_COUNT}"
	printf ${INPUT} | dd of="${3}" bs=1 seek=${1} count=${BYTE_COUNT} conv=notrunc 
}

# converts hex string to a decimal number
# arg 1: hex string to convert ie "0xABCD"
# returns: decimal number such as "123"
convert_hex_to_number() {
	debug_log "convert_hex_to_number input: ${1}"
	# from: https://stackoverflow.com/questions/378829/convert-decimal-to-hexadecimal-in-unix-shell-script
	# input is something like "0x0FFF", convert it to a number:
	NUMBER=`echo $((${1}))`
	debug_log "convert_hex_to_number result: ${NUMBER}"
	echo -n "${NUMBER}"
}

# converts decimal number to a hex string
# arg 1: decimal number such as "123"
# returns: hex string ie "0xABCD"
convert_number_to_hex() {
	debug_log "convert_number_to_hex input: ${1}"
	# from: https://stackoverflow.com/questions/378829/convert-decimal-to-hexadecimal-in-unix-shell-script
	# and: http://wiki.bash-hackers.org/commands/builtin/printf
	# input example: 12
	RESULT=`printf "%X" "${1}"`
	# result is now "C", we want to zero pad this to be "0C" if there's an odd number of digits
	RESULT=$(fix_hex_padding "0x${RESULT}")
	RESULT=`echo -n "${RESULT}" | sed 's/0x//'` # strip 0x off front:
	debug_log "convert_number_to_hex initial hex: ${RESULT}"
	REMAINDER=`expr ${#RESULT} % 2`
	debug_log "convert_number_to_hex remainder: ${REMAINDER}"
	if [ ${REMAINDER} -eq 1 -o "0" = "${RESULT}" ]; then
		# odd number of hex digits, add a zero at front
		RESULT="0${RESULT}"
	fi
	# add "0x" to beginning of result
	RESULT="0x${RESULT}"
	debug_log "convert_number_to_hex result: ${RESULT}"
	echo -n "${RESULT}"
}

# adds an extra "0" to the beginning of a hex string that has an odd number of characters in it, ie "0xF" -> "0x0F"
# arg 1: hex string to pad, ie "0xF"
# returns: padded hex string, ie "0x0F"
fix_hex_padding() {
	debug_log "fix_hex_padding fixing input: ${1}"
	RESULT=`echo -n "${1}" | sed 's/0x//'` # strip 0x off front:
	# from: https://stackoverflow.com/questions/17368067/length-of-string-in-bash
	# and: http://tldp.org/LDP/abs/html/ops.html
	REMAINDER=`expr ${#RESULT} % 2`
	if [ ${REMAINDER} -eq 1 -o "0" = "${RESULT}" ]; then
		# odd number of hex digits, add a zero at front
		RESULT="0${RESULT}"
	fi
	RESULT="0x${RESULT}"
	debug_log "fix_hex_padding result: ${RESULT}"
	echo -n "${RESULT}"
}

# converts hex string to an ascii string
# arg 1: hex string to convert ie "0xABCD"
# returns: ascii string such as "Jason"
convert_hex_to_ascii_string() {
	debug_log "convert_hex_to_ascii_string input: ${1}"
	# from: https://stackoverflow.com/questions/13160309/conversion-hex-string-into-ascii-in-bash-command-line
	# input is like 0x424141
	INPUT=`echo -n "${1}" | sed 's/0x//'` # strip 0x off front:
	# now input is 424141
	# echo needs a format of \x41\x42 with "\x" between each hex pair to print hex as ascii
	# put the "\x" in the string
	INPUT=`echo -n "${INPUT}" | sed 's/\(..\)/\\\\x\1/g'`
	debug_log "convert_hex_to_ascii_string input with '\x' between each pair: ${INPUT}"
	# now input is \x42\x41\x41
	RESULT=`echo -n -e "${INPUT}"`
	debug_log "convert_hex_to_ascii_string result: ${RESULT}"
	# now result is BAA
	echo -n "${RESULT}"
}

# converts ascii string to a hex string
# arg 1: ascii string such as "Jason"
# returns: hex string ie "0xABCD"
convert_ascii_string_to_hex() {
	debug_log "convert_ascii_string_to_hex input: ${1}"
	# from: https://stackoverflow.com/questions/5724761/ascii-hex-convert-in-bash/5725125
	RESULT="0x`echo -n "${1}" | hexdump -e '/1 "%02X"'`"
	debug_log "convert_ascii_string_to_hex result: ${RESULT}"
	echo -n "${RESULT}"
}


# extracts a decimal number from bytes in a file
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: length of bytes to read
# arg 3: file to extract from
# returns: decimal number such as "123"
extract_number_from_file() {
	debug_log "extract_number_from_file offset: ${1}, bytes to read: ${2}, file: ${3}"
	HEX_BYTES=$(extract_bytes ${1} ${2} "${3}")
	NUMBER=$(convert_hex_to_number ${HEX_BYTES})
	debug_log "extract_number_from_file result: ${NUMBER}"
	echo -n "${NUMBER}"
}

# extracts a decimal number from bytes in a file where hex bytes in file are reversed (ie should be 0x021A but are read as 0x1A02)
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: length of bytes to read
# arg 3: file to extract from
# returns: decimal number such as "123"
extract_reversed_number_from_file() {
	debug_log "extract_reversed_number_from_file offset: ${1}, bytes to read: ${2}, file: ${3}"
	HEX_BYTES=$(extract_bytes ${1} ${2} "${3}")
	HEX_BYTES_REVERSED=$(reverse_hex_order "${HEX_BYTES}")
	NUMBER=$(convert_hex_to_number ${HEX_BYTES_REVERSED})
	debug_log "extract_number_from_file result: ${NUMBER}"
	echo -n "${NUMBER}"
}


# extracts a ascii string from bytes in a file
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: length of bytes to read
# arg 3: file to extract from
# returns: ascii string such as "Jason"
extract_string_from_file() {
	debug_log "extract_string_from_file offset: ${1}, bytes to read: ${2}, file: ${3}"
	HEX_BYTES=$(extract_bytes ${1} ${2} "${3}")
	ASCII_STRING=$(convert_hex_to_ascii_string ${HEX_BYTES})
	debug_log "extract_string_from_file result: ${ASCII_STRING}"
	echo -n "${ASCII_STRING}"
}

# replaces the given number in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: number to write in decimal ie "123"
# arg 3: file to write to
# returns: nothing
replace_number_in_file() {
	debug_log "replace_number_in_file offset: ${1}, number to write: ${2}, file: ${3}"
	HEX_BYTES=$(convert_number_to_hex "${2}")
	replace_bytes ${1} "${HEX_BYTES}" "${3}"
}

# replaces the given number in a file with reversed hex bytes written to disk
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: number to write in decimal ie "123"
# arg 3: file to write to
# returns: nothing
replace_reversed_number_in_file() {
	debug_log "replace_reversed_number_in_file offset: ${1}, number to write: ${2}, file: ${3}"
	HEX_BYTES=$(convert_number_to_hex "${2}")
	HEX_BYTES_REVERSED=$(reverse_hex_order "${HEX_BYTES}")
	replace_bytes ${1} "${HEX_BYTES_REVERSED}" "${3}"
}


# replaces the given string in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: ascii string to write ie "Jason"
# arg 3: file to write to
# returns: nothing
replace_string_in_file() {
	debug_log "replace_string_in_file offset: ${1}, string to write: ${2}, file: ${3}"
	HEX_BYTES=$(convert_ascii_string_to_hex "${2}")
	replace_bytes ${1} "${HEX_BYTES}" "${3}"
}