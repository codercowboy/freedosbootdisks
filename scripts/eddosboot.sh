#!/bin/bash

#TODO: put license, desc, email, warning about osx here

#DEBUG_HEXLIB="true"

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
	echo "  COPY_BOOT_SECTOR [SOURCE FILE] [TARGET FILE] - copy boot sector from source file to target file, overwritting target's boot sector if target exists"
	echo ""
	echo "---"
	echo ""
	echo "  SHOW ALL [FILE] - displays all boot record properties for specified file"
	echo "  SHOW SECTOR_SIZE [FILE] - display sector size"
	echo "  SHOW SECTOR_COUNT [FILE] - display sector count"
	echo ""
	echo "---"
	echo ""
	echo "  CHANGE SECTOR_SIZE [SIZE] [FILE] - changes file's boot record sector size to specified size in bytes"
	echo "  CHANGE SECTOR_COUNT [COUNT] [FILE] - change file's boot record sector count"
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

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"

if [ "DEBUG" = "${1}" ]; then
	DEBUG_HEXLIB="true"
	shift
fi

if [ ! -f "${SCRIPT_HOME}/hexlib.sh" ]; then
	print_usage "Cannot find hexlib.sh, should be in path: ${SCRIPT_HOME}/hexlib.sh"
fi

source "${SCRIPT_HOME}/hexlib.sh"

debug_log "SCRIPT_HOME: ${SCRIPT_HOME}"
debug_log "Arguments: ${@}"

if [ -z "${1}" -o "HELP" = "${1}" ]; then
	print_usage;
	exit 1
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
	elif [ ! -r "${FILE}" ]; then
		print_usage "Invalid file. It's not a file or isn't readable: ${FILE}"
	fi 

	debug_log "Mode: SHOW, file: ${FILE}"

	# from: https://thestarman.pcministry.com/asm/mbr/DOS50FDB.htm
	# sector size: 0x0B-0x0C (2 bytes)
	# sector count: 0x13-0x14 (2 bytes)

	DECIMAL_ADDRESS=$(convert_hex_to_number "0x0B")
	SECTOR_SIZE=`extract_reversed_number_from_file "${DECIMAL_ADDRESS}" 2 "${FILE}"`
	DECIMAL_ADDRESS=$(convert_hex_to_number "0x13")
	SECTOR_COUNT=`extract_reversed_number_from_file "${DECIMAL_ADDRESS}" 2 "${FILE}"`

	if [ "ALL" = "${ACTION}" ]; then
		echo "Boot properties for file: ${FILE}"
		echo "  Sector size: ${SECTOR_SIZE}"
		echo "  Sector count: ${SECTOR_COUNT}"
	elif [ "SECTOR_SIZE" = "${ACTION}" ]; then
		echo -n "${SECTOR_SIZE}"
	elif [ "SECTOR_COUNT" = "${ACTION}" ]; then
		echo -n "${SECTOR_COUNT}"
	elif [ "VOLUME_LABEL" = "${ACTION}" ]; then	
		echo -n "${VOLUME_LABEL}"
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

	# from: https://thestarman.pcministry.com/asm/mbr/DOS50FDB.htm
	# sector size: 0x0B-0x0C (2 bytes)
	# sector count: 0x13-0x14 (2 bytes)

	HEX_BYTES=$(convert_number_to_hex "${VALUE}")
	# if only one byte is in number ie 0x01, change it to 0x0001
	if [ ${#HEX_BYTES} -eq 4 ]; then
		HEX_BYTES=`echo -n ${HEX_BYTES} | sed 's/0x/0x00/'`
	fi
	HEX_BYTES_REVERSED=$(reverse_hex_order "${HEX_BYTES}")	
	DECIMAL_ADDRESS=""
	if [ "SECTOR_SIZE" = "${ACTION}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x0B")
	elif [ "SECTOR_COUNT" = "${ACTION}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x13")
	else
		print_usage "Unsupported 'CHANGE' mode: ${ACTION}"
	fi
	replace_bytes "${DECIMAL_ADDRESS}" "${HEX_BYTES_REVERSED}" "${FILE}"
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
elif [ "COPY_BOOT_SECTOR" = "${OPERATION}" ]; then	
	SOURCE_FILE="${ACTION}"
	if [ -z "${SOURCE_FILE}" ]; then
		print_usage "Invalid source file: ${SOURCE_FILE}"
	elif [ ! -r "${SOURCE_FILE}" ]; then
		print_usage "Invalid source file. It's not a file or isn't readable: ${SOURCE_FILE}"
	fi 
	TARGET_FILE="${1}"
	if [ -z "${TARGET_FILE}" ]; then
		print_usage "Invalid target file: ${TARGET_FILE}"
	elif [ -f "${TARGET_FILE}" -a ! -w "${SOURCE_FILE}" ]; then
		print_usage "Invalid target file. It's not a file or isn't writable: ${TARGET_FILE}"
	fi 
	debug_log "Mode: COPY_BOOT_SECTOR, source file: ${SOURCE_FILE}, target file: ${TARGET_FILE}"

	dd if=${SOURCE_FILE} of=${TARGET_FILE} bs=512 count=1 conv=notrunc
else
	print_usage "Unsupported operation: ${OPERATION}"
fi
