#!/bin/bash

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

# extracts bytes from file from specified offset in a hex string format
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: count of bytes to read
# arg 3: file to extract from
# returns: bytes in hex format ie "0xABCD"
extract_bytes() {
	debug_log "extract_bytes offset: ${1}, byte count: ${2}, file: ${3}"
	echo "0xAA"
}

# replace bytes to file at specified offset
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: count of bytes to write
# arg 3: bytes to write in hex string format ie "0xABCD"
# arg 4: file to replace bytes in
replace_bytes() {
	debug_log "replace_bytes offset: ${1}, byte count: ${2}, bytes to write: ${3}, file: ${4}"
	echo "Not written yet"
}

# for some reason the boot sector has bytes backwards, ie instead of 0xFD0A we'd have 0x0AFD
# arg 1: hex string to convert ie "0xCDAB"
# returns hex string ie "0xABCD"
fix_hex_order() {
	debug_log "fix_hex_order input: ${1}"
	echo "0xAA"
}

# converts hex string to a decimal number
# arg 1: hex string to convert ie "0xABCD"
# returns: decimal number such as "123"
convert_hex_to_number() {
	debug_log "convert_hex_to_number input: ${1}"
	echo "Not written yet"
}

# converts decimal number to a hex string
# arg 1: decimal number such as "123"
# returns: hex string ie "0xABCD"
convert_number_to_hex() {
	debug_log "convert_number_to_hex input: ${1}"
	echo "Not written yet"
}

# converts hex string to an ascii string
# arg 1: hex string to convert ie "0xABCD"
# returns: ascii string such as "Jason"
convert_hex_to_ascii_string() {
	debug_log "convert_hex_to_ascii_string input: ${1}"
	echo "blah"
}

# converts ascii string to a hex string
# arg 1: ascii string such as "Jason"
# returns: hex string ie "0xABCD"
convert_ascii_string_to_hex() {
	debug_log "convert_ascii_string_to_hex input: ${1}"
	echo "Not written yet"
}


# extracts a decimal number from bytes in a file
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: length of bytes to read
# arg 3: file to extract from
# returns: decimal number such as "123"
extract_number_from_file() {
	debug_log "extract_number_from_file offset: ${1}, bytes to read: ${2}, file: ${3}"
	HEX_BYTES=$(extract_bytes ${1} ${2} "${3}")
	FIXED_HEX_BYTES=$(fix_hex_order ${HEX_BYTES})
	NUMBER=$(convert_hex_to_number ${FIXED_HEX_BYTES})
	return ${NUMBER}
}

# extracts a ascii string from bytes in a file
# arg 1: byte offset to start reading from in decimal ie "123"
# arg 2: length of bytes to read
# arg 3: file to extract from
# returns: ascii string such as "Jason"
extract_string_from_file() {
	debug_log "extract_string_from_file offset: ${1}, bytes to read: ${2}, file: ${3}"
	HEX_BYTES=$(extract_bytes ${1} ${2} "${3}")
	FIXED_HEX_BYTES=$(fix_hex_order ${HEX_BYTES})
	ASCII_STRING=$(convert_hex_to_ascii_string ${FIXED_HEX_BYTES})
	echo "${ASCII_STRING}"
}


# replaces the given string in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: length of bytes to write
# arg 3: number to write in decimal ie "123"
# arg 4: file to write to
replace_number_in_file() {
	debug_log "replace_number_in_file offset: ${1}, bytes to write: ${2}, number to write: ${3}, file: ${4}"
	#TODO: zero out the bytes first
	HEX_BYTES=$(convert_number_to_hex "${3}")
	FIXED_HEX_BYTES=$(fix_hex_order ${HEX_BYTES})
	replace_bytes ${1} ${2} ${FIXED_HEX_BYTES} "${FILE}"
}


# replaces the given string in a file
# arg 1: byte offset to start writing to in decimal ie "123"
# arg 2: length of bytes to write
# arg 3: ascii string to write ie "Jason"
# arg 4: file to write to
replace_string_in_file() {
	debug_log "replace_string_in_file offset: ${1}, bytes to write: ${2}, string to write: ${3}, file: ${4}"
	HEX_BYTES=$(convert_ascii_string_to_hex "${3}")
	#TODO: pad zeros to fill out bytes to write size buffer
	FIXED_HEX_BYTES=$(fix_hex_order ${HEX_BYTES})
	replace_bytes ${1} ${2} ${FIXED_HEX_BYTES} "${FILE}"
}

if [ "DEBUG" = "${1}" ]; then
	DEBUG_EDDOSBOOT="true"
	shift
fi

debug_log "SCRIPT_HOME: ${SCRIPT_HOME}"
debug_log "Arguments: ${@}"

if [ "TEST" = "${1}" ]; then
	TEST_FILE="${SCRIPT_HOME}/test.tmp"
	debug_log "TEST_FILE: ${TEST_FILE}"
	if [ -f "${TEST_FILE}" ]; then
		rm "${TEST_FILE}"
	fi
	echo "ABCD" > "${TEST_FILE}"
	
	RESULT=$(extract_string_from_file 0 4 "${TEST_FILE}")
	if [ ! "ABCD" = "${RESULT}" ]; then
		echo "Test 1.A failed, should be ABCD but was: ${RESULT}"
		exit 1
	fi

	RESULT=`extract_string_from_file 1 2 "${TEST_FILE}"`
	if [ ! "BC" = "${RESULT}" ]; then
		echo "Test 1.B failed, should be BC but was: ${RESULT}"
		exit 1
	fi

	RESULT=`extract_string_from_file 3 1 "${TEST_FILE}"`
	if [ ! "D" = "${RESULT}" ]; then
		echo "Test 1.C failed, should be D but was: ${RESULT}"
		exit 1
	fi

	RESULT=`fix_hex_order "0x00ABCD03"`
	if [ ! "0x03CDAB00" = "${RESULT}" ]; then
		echo "Test 2.a failed, should be 0x03CDAB00 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`fix_hex_order "0x00AB"`
	if [ ! "0xAB00" = "${RESULT}" ]; then
		echo "Test 2.b failed, should be 0xAB00 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`fix_hex_order "0xAB"`
	if [ ! "0xAB" = "${RESULT}" ]; then
		echo "Test 2.c failed, should be 0xAB but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x00"`
	if [ ! 0 -eq ${RESULT} ]; then
		echo "Test 3.a failed, should be 0 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x01"`
	if [ ! 1 -eq ${RESULT} ]; then
		echo "Test 3.b failed, should be 1 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x14"`
	if [ ! 19 -eq ${RESULT} ]; then
		echo "Test 3.c failed, should be 19 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x0F"`
	if [ ! 15 -eq ${RESULT} ]; then
		echo "Test 3.d failed, should be 15 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x0A"`
	if [ ! 10 -eq ${RESULT} ]; then
		echo "Test 3.e failed, should be 10 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0x0001"`
	if [ ! 1 -eq ${RESULT} ]; then
		echo "Test 3.f failed, should be 1 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_number "0xFF00FF"`
	if [ ! 1 -eq ${RESULT} ]; then
		echo "Test 3.g failed, should be 1 but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_ascii_string "0x0000FF"`
	if [ ! "Jason" = "${RESULT}" ]; then
		echo "Test 4.a failed, should be 'Jason' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_hex_to_ascii_string "0x0000FF000"` # zero padding at end should be trimmed
	if [ ! "Jason" = "${RESULT}" ]; then
		echo "Test 4.b failed, should be 'Jason' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_number_to_hex 0`
	if [ ! "0x00" = "${RESULT}" ]; then
		echo "Test 5.a failed, should be '0x00' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_number_to_hex 1`
	if [ ! "0x01" = "${RESULT}" ]; then
		echo "Test 5.b failed, should be '0x01' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_number_to_hex 15`
	if [ ! "0x0F" = "${RESULT}" ]; then
		echo "Test 5.c failed, should be '0x0F' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_number_to_hex 255`
	if [ ! "0xFF" = "${RESULT}" ]; then
		echo "Test 5.d failed, should be '0xFF' but was: ${RESULT}"
		exit 1
	fi

	RESULT=`convert_number_to_hex 123456789`
	if [ ! "0xFF" = "${RESULT}" ]; then
		echo "Test 5.e failed, should be '0xFF' but was: ${RESULT}"
		exit 1
	fi

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
