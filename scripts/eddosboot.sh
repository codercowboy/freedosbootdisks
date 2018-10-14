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

if [ "NO_OP" = "${1}" ]; then
	# do nothing, no op mode
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
elif [ "NO_OP" = "${OPERATION}" ]; then	
	echo "eddosboot.sh is in no operation mode (used for unit tests)."
else
	print_usage "Unsupported operation: ${OPERATION}"
fi
