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
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SECTOR SIZE] [SECTOR COUNT] [FILE] - creates boot disk w/ given sector specifications"
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
	echo "  CREATE BOOT_SECTOR [VOLUME LABEL] [SECTOR SIZE] [SECTOR COUNT] [FILE] - create boot sector with given sector specifications"
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
	if [ ! -z "${1}" ]; then
		echo ""
		echo "ERROR: ${1}"
		exit 1
	fi
}

# changes a boot sector property
# arg 1: mode: SECTOR_SIZE or SECTOR_COUNT
# arg 2: value to write
# arg 3: boot sector file
change_boot_sector_property() {
	# from: https://thestarman.pcministry.com/asm/mbr/DOS50FDB.htm
	# sector size: 0x0B-0x0C (2 bytes)
	# sector count: 0x13-0x14 (2 bytes)

	HEX_BYTES=$(convert_number_to_hex "${2}")
	# if only one byte is in number ie 0x01, change it to 0x0001
	if [ ${#HEX_BYTES} -eq 4 ]; then
		HEX_BYTES=`echo -n ${HEX_BYTES} | sed 's/0x/0x00/'`
	fi
	HEX_BYTES_REVERSED=$(reverse_hex_order "${HEX_BYTES}")	
	DECIMAL_ADDRESS=""
	if [ "SECTOR_SIZE" = "${1}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x0B")
	elif [ "SECTOR_COUNT" = "${1}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x13")
	else
		print_usage "Unsupported 'CHANGE' mode: ${ACTION}"
	fi
	replace_bytes "${DECIMAL_ADDRESS}" "${HEX_BYTES_REVERSED}" "${3}"
}

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"
BUILD_HOME="${SCRIPT_HOME}/../build"
SOURCE_BOOT_DISK="${SCRIPT_HOME}/../lib/v86.freedos.boot.disk.img"

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
	change_boot_sector_property "${ACTION}" "${VALUE}" "${FILE}"
elif [ "CREATE" = "${OPERATION}" ]; then
	if [ ! -f "${SOURCE_BOOT_DISK}" ]; then
		echo "ERROR: source FreeDOS boot disk image is missing: ${SOURCE_BOOT_DISK}"
		exit 1
	fi

	VOLUME_LABEL="${1}"
	if [ -z "${VOLUME_LABEL}" ]; then #TODO: check for valid volume label here too
		print_usage "Invalid volume label: ${VOLUME_LABEL}"
	fi
	shift
	
	FILE_SIZE="1.4MB"
	SECTOR_SIZE="512"
	SECTOR_COUNT=""
	FILE=""
	if [ ! -z "${3}" ]; then #if there are three arguments, it's [SECTOR COUNT] [SECTOR SIZE] [FILE]
		if [ -z "${2}" -o -z "${1}" ]; then
			print_usage "Invalid 'CREATE' operation arguments: ${@}"
		fi
		FILE="${3}"
		SECTOR_COUNT="${2}"
		SECTOR_SIZE="${1}"
	elif [ ! -z "${2}" ]; then #if there are two arguments it's [SIZE] [FILE]
		if [ -z "${1}" ]; then
			print_usage "Invalid 'CREATE' operation arguments: ${@}"
		fi
		FILE="${2}"
		FILE_SIZE="${1}"
	elif [ ! -z "${1}" ]; then #if there's only one argument it's [FILE]
		FILE="${1}"
	else 
		print_usage "Invalid 'CREATE' operation arguments: ${@}"
	fi

	if [ "2.8MB" = "${FILE_SIZE}" ]; then
		SECTOR_COUNT=$((2880 * 2))
	elif [ "1.4MB" = "${FILE_SIZE}" ]; then
		SECTOR_COUNT=$((1440 * 2))
	elif [ "720K" = "${FILE_SIZE}" ]; then
		SECTOR_COUNT=$((720 * 2))
	elif [ "320K" = "${FILE_SIZE}" ]; then
		SECTOR_COUNT=$((320 * 2))
	elif [ "160K" = "${FILE_SIZE}" ]; then
		SECTOR_COUNT=$((160 * 2))
	else
		print_usage "Unsupported 'CREATE' mode file size: '${FILE_SIZE}', supported sizes are: 2.8MB, 1.4MB, 720K, 360K, and 160K"
	fi

	# copy the source v86 boot sector to a tmp file
	mkdir -p "${BUILD_HOME}"
	TMP_BOOT_SECTOR="${BUILD_HOME}/bootsector.tmp"
	dd if="${SOURCE_BOOT_DISK}" of="${TMP_BOOT_SECTOR}" bs=512 count=1

	#fix the sector size and count in the boot sector
	change_boot_sector_property SECTOR_SIZE "${SECTOR_SIZE}" "${TMP_BOOT_SECTOR}"
	change_boot_sector_property SECTOR_COUNT "${SECTOR_COUNT}" "${TMP_BOOT_SECTOR}"

	# from: https://apple.stackexchange.com/questions/338718/creating-bootable-freedos-dos-floppy-diskette-img-file-for-v86-on-osx
	if [ "BOOT_DISK" = "${ACTION}" ]; then
		echo "Creating ${FILE_SIZE} FreeDOS boot disk with ${SECTOR_COUNT} sectors, sector size is ${SECTOR_SIZE}, file: ${FILE}"

		# create an empty img file with all zeros in it
		dd if=/dev/zero of="${FILE}" bs=${SECTOR_SIZE} count=${SECTOR_COUNT}		

		# format the floppy image as FAT12
		newfs_msdos -B "${TMP_BOOT_SECTOR}" -v "${VOLUME_LABEL}" -f ${SECTOR_COUNT} -b ${SECTOR_SIZE} -S ${SECTOR_SIZE} -r 1 -F 12 "${FILE}"

		# remove temporary boot sector file
		rm "${TMP_BOOT_SECTOR}"

		# mount our source freedos image fetched from the V86 demo page, and copy our minimal files from it
		# this mounts as /Volumes/FREEDOS

		hdiutil attach -readonly "${SOURCE_BOOT_DISK}"
		cp /Volumes/FREEDOS/COMMAND.COM "${BUILD_HOME}/"
		cp /Volumes/FREEDOS/KERNEL.SYS "${BUILD_HOME}/"
		cp /Volumes/FREEDOS/CONFIG.SYS "${BUILD_HOME}/"
		hdiutil eject /Volumes/FREEDOS/

		# mount our target .img file we just created, it'll mount as /Volumes/${VOLUME_LABEL}, copy our minimal files to it
		hdiutil attach "${FILE}"
		cp "${BUILD_HOME}/COMMAND.COM" "/Volumes/${VOLUME_LABEL}/"
		cp "${BUILD_HOME}/KERNEL.SYS" "/Volumes/${VOLUME_LABEL}/"
		cp "${BUILD_HOME}/CONFIG.SYS" "/Volumes/${VOLUME_LABEL}/"
		hdiutil eject "/Volumes/${VOLUME_LABEL}/"

		echo "Finished creating boot diskette image: ${FILE}"

	elif [ "BOOT_SECTOR" = "${ACTION}" ]; then
		echo "Creating ${FILE_SIZE} FreeDOS boot sector with ${SECTOR_COUNT} sectors, sector size is ${SECTOR_SIZE}, file: ${FILE}"
		cp "${TMP_BOOT_SECTOR}" "${FILE}"
	else 
		rm "${TMP_BOOT_SECTOR}"
		print_usage "Unsupported 'CREATE' operation: ${ACTION}, supported operations are BOOT_DISK and BOOT_SECTOR"		
	fi		
	rm "${TMP_BOOT_SECTOR}"	
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

	dd if="${SOURCE_FILE}" of="${TARGET_FILE}" bs=512 count=1 conv=notrunc
else
	print_usage "Unsupported operation: ${OPERATION}"
fi
