#!/bin/bash

#TODO: put license, desc, email, warning about osx here

#DEBUG_EDDOSBOOT="true"

print_usage() {
	echo ""
	echo "eddosboot - MacOS tools for managing minimal FreeDOS boot disk image files"
	echo "  written by Jason Baker (jason@codercowboy.com), 2018"
	echo ""
	echo "USAGE: eddosboot [COMMAND] [FILE]"
	echo ""
	echo "Commands:"
	echo ""
	echo " The following commands create a minimal FreeDOS boot disk in the specified file in .img format."
	echo " The disk will be FAT12 formatted. The disk will contain FreeDOS KERNEL.SYS, CONFIG.SYS, and COMMAND.COM files."
	echo ""
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [FILE] - creates a 1.4MB FreeDOS boot disk"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SECTOR COUNT] [SECTOR SIZE] [FILE] - creates boot disk w/ given sector specifications"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SIZE] [FILE] - creates a boot disk with specified file size"
	echo "      Supported boot disk file sizes: 160K 320K 720K 1.4MB"
	echo ""
	echo "  Example Usage: CREATE_BOOT_DISK MYDISK 720K disk.img"
	echo ""
	echo "  Example above would create a 720K FreeDOS boot disk in the disk.img file with the volume label of MYDISK."
	echo ""
	echo "---"
	echo ""
	echo " The following commands create 512 byte FreeDOS boot sectors in specified file in .img format."
	echo " If specified file exists, first 512 bytes of file will be overwritten with new boot record."
	echo " If specified file is new, newly created file will be 512 bytes and contain boot sector."
	echo ""
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [FILE] - creates a 1.4MB FreeDOS .img boot sector."
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [SECTOR COUNT] [SECTOR SIZE] [FILE] - create boot sector with given sector specifications"
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [SIZE] [FILE] - create boot sector with specified standard diskette size"
	echo "      Supported boot disk sizes: 160K 320K 720K 1.4MB"
	echo ""
	echo "---"
	echo ""
	echo "  EXTRACT_BOOT_SECTOR [SOURCE FILE] [TARGET FILE] - extract boot record from source file, save record in target file"
	echo "  COPY_BOOT_SECTOR [SOURCE FILE] [TARGET FILE] - copy first boot sector from source file to target file."
	echo ""
	echo "---"
	echo ""
	echo "  SHOW ALL [FILE] - displays all boot record properties for specified file"
	echo "  SHOW SECTOR_SIZE [FILE] - display sector size"
	echo "  SHOW SECTOR_COUNT [FILE] - display sector count"
	echo "  SHOW CYLINDER_COUNT [FILE] - display cylinder count"
	echo "  SHOW HEAD_COUNT [FILE] - display head count"
	echo "  SHOW VOLUME_LABEL [FILE] - display volume label"	
	echo ""
	echo "---"
	echo ""
	echo "  CHANGE SECTOR_SIZE [SIZE] [FILE] - changes file's boot record sector size to specified size in bytes"
	echo "  CHANGE SECTOR_COUNT [COUNT] [FILE] - change file's boot record sector count"
	echo "  CHANGE CYLINDER_COUNT [COUNT] [FILE] - change file's boot record cylinder count"
	echo "  CHANGE HEAD_COUNT [COUNT] [FILE] - change file's boot record head count"
	echo "  CHANGE VOLUME_LABEL [LABEL] [FILE] - change file's boot record volume label"
	echo ""
	#//TODO: put in license
	#//TODO: put in reference to github
	#//TODO: put in references to other things (freeDOS, v86, virtualbox, qemu, boot record reference)
	if [ ! -z "${1}" ]; then
		echo ""
		echo "ERROR: ${1}"
		exit 1
	fi
}

debug_log() {
	if [ "true" = "${DEBUG_EDDOSBOOT}" ]; then
		echo "DEBUG: ${1}" > /dev/stderr
	fi
}

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"

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
	OUTPUT="0x`dd if=${3} count=${2} bs=1 skip=${1} conv=notrunc | hexdump -e '"%X"'`" 
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
	printf ${INPUT} | dd of=${3} bs=1 seek=${1} count=${BYTE_COUNT} conv=notrunc 
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
	# from: https://stackoverflow.com/questions/17368067/length-of-string-in-bash
	# and: http://tldp.org/LDP/abs/html/ops.html
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

# converts hex string to an ascii string
# arg 1: hex string to convert ie "0xABCD"
# returns: ascii string such as "Jason"
convert_hex_to_ascii_string() {
	debug_log "convert_hex_to_ascii_string input: ${1}"
	# from: https://stackoverflow.com/questions/13160309/conversion-hex-string-into-ascii-in-bash-command-line
	# input is like 0x424141
	# strip 0x off front:
	INPUT=`echo -n "${1}" | sed 's/0x//'`
	debug_log "convert_hex_to_ascii_string input with '0x' stripped from front: ${INPUT}"
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
	NUMBER=$(convert_hex_to_number ${FIXED_HEX_BYTES})
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

# replaces the given string in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: number to write in decimal ie "123"
# arg 3: file to write to
# returns: nothing
replace_number_in_file() {
	debug_log "replace_number_in_file offset: ${1}, number to write: ${2}, file: ${3}"
	#TODO: zero out the bytes first
	HEX_BYTES=$(convert_number_to_hex "${3}")
	replace_bytes ${1} "${HEX_BYTES}" "${3}"
}


# replaces the given string in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: ascii string to write ie "Jason"
# arg 3: file to write to
# returns: nothing
replace_string_in_file() {
	debug_log "replace_string_in_file offset: ${1}, string to write: ${2}, file: ${3}"
	HEX_BYTES=$(convert_ascii_string_to_hex "${2}")
	#TODO: pad zeros to fill out bytes to write size buffer
	replace_bytes ${1} "${HEX_BYTES}" "${3}"
}

if [ "DEBUG" = "${1}" ]; then
	DEBUG_EDDOSBOOT="true"
	shift
fi

debug_log "SCRIPT_HOME: ${SCRIPT_HOME}"
debug_log "Arguments: ${@}"

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

if [ "TEST" = "${1}" ]; then
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
	echo "hello"
	verify_test "Test 1.c" "D" "${RESULT}"

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

	//TODO: extract_number_from_file
	//TODO: replace_number_in_file

	rm "${TEST_FILE}"

	exit 0
fi

if [ -z "${1}" -o "HELP" = "${1}" ]; then
	print_usage;
elif [ -z "${2}" -o -z "${3}" ]; then
	print_usage "Incorrect arguments: ${@}"
fi


OPERATION="${1}"
debug_log "OPERATION: ${OPERATION}"
shift	

ACTION="${1}"
debug_log "ACTION: ${ACTION}"
shift


if [ "SHOW" = "${OPERATION}" ]; then
	FILE="${1}"
	if [ -z "${FILE}" ]; then
		print_usage "Invalid file: ${FILE}"
	elif [ ! -r "${FILE}"]; then
		print_usage "Invalid file. It's not a file or isn't readable: ${FILE}"
	fi 

	debug_log "Mode: SHOW, file: ${FILE}"

	SECTOR_SIZE=`extract_number_from_file 0 0 "${FILE}"`
	SECTOR_COUNT=`extract_number_from_file 0 0 "${FILE}"`
	CYLINDER_COUNT=`extract_number_from_file 0 0 "${FILE}"`
	HEAD_COUNT=`extract_number_from_file 0 0 "${FILE}"`
	VOLUME_LABEL=`extract_string_from_file 0 0 "${FILE}"`

	if [ "ALL" = "${ACTION}" ]; then
		echo "Boot properties for file: ${FILE}"
		echo "  Sector size: ${SECTOR_SIZE}"
		echo "  Sector count: ${SECTOR_COUNT}"
		echo "  Cylinder count: ${CYLINDER_COUNT}"
		echo "  Head count: ${HEAD_COUNT}"
		echo "  Volume label: ${VOLUME_LABEL}"
	elif [ "SECTOR_SIZE" = "${ACTION}" ]; then
		echo "${SECTOR_SIZE}"
	elif [ "SECTOR_COUNT" = "${ACTION}" ]; then
		echo "${SECTOR_COUNT}"
	elif [ "CYLINDER_COUNT" = "${ACTION}" ]; then
		echo "${CYLINDER_COUNT}"
	elif [ "HEAD_COUNT" = "${ACTION}" ]; then
		echo "${HEAD_COUNT}"
	elif [ "VOLUME_LABEL" = "${ACTION}" ]; then	
		echo "${VOLUME_LABEL}"
	else 
		print_usage "Unsupported 'SHOW' mode: ${ACTION}"
	fi
elif [ "CHANGE" = "${OPERATION}" ]; then
	VALUE="${1}"
	if [ -z "${VALUE}" ]; then
		print_usage "Invalid 'CHANGE' mode value: ${VALUE}"
	fi
	shift

	FILE="${1}"
	if [ -z "${FILE}" ]; then
		print_usage "Invalid file: ${FILE}"
	elif [ ! -w "${FILE}" ]; then
		print_usage "Invalid file. It's not a file or isn't writable: ${FILE}"
	fi 

	debug_log "Mode: CHANGE, value: ${VALUE}, file: ${FILE}"

	if [ "SECTOR_SIZE" = "${ACTION}" ]; then
		# TODO: check that it's a valid sector size
		echo ""
	elif [ "SECTOR_COUNT" = "${ACTION}" ]; then
		# TODO: check that it's a valid sector count
		echo ""
	elif [ "CYLINDER_COUNT" = "${ACTION}" ]; then
		# TODO: check that it's a valid cylinder count
		echo ""
	elif [ "HEAD_COUNT" = "${ACTION}" ]; then
		# TODO: check that it's a valid head count
		echo ""
	elif [ "VOLUME_LABEL" = "${ACTION}" ]; then		
		# TODO: check that it's a valid volume label
		echo ""
	else
		print_usage "Unsupported 'CHANGE' mode: ${ACTION}"
	fi
elif [ "CREATE" = "${OPERATION}" ]; then
	VOLUME_LABEL="${1}"
	if [ -z "${VOLUME_LABEL}" ]; then #TODO: check for valid volume label here too
		print_usage "Invalid volume label: ${VOLUME_LABEL}"
	fi
	shift

	echo "  CREATE BOOT_DISK [VOLUME LABEL] [FILE] - creates a 1.4MB FreeDOS boot disk"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SECTOR COUNT] [SECTOR SIZE] [FILE] - creates boot disk w/ given sector specifications"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SIZE] [FILE] - creates a boot disk with specified file size"
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [FILE] - creates a 1.4MB FreeDOS .img boot sector."
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [SECTOR COUNT] [SECTOR SIZE] [FILE] - create boot sector with given sector specifications"
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [SIZE] [FILE] - create boot sector with specified standard diskette size"
	
elif [ "EXTRACT_BOOT_SECTOR" = "${OPERATION}" ]; then	
	echo "  EXTRACT_BOOT_SECTOR [SOURCE FILE] [TARGET FILE] - extract boot record from source file, save record in target file"
elif [ "COPY_BOOT_SECTOR" = "${OPERATION}" ]; then	
	echo "  COPY_BOOT_SECTOR [SOURCE FILE] [TARGET FILE] - copy first boot sector from source file to target file."
else
	print_usage "Unsupported operation: ${OPERATION}"
fi