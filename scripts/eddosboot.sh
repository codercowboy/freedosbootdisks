#!/bin/bash

#################################################################################
#
# eddosboot.sh - FreeDOS boot disk/sector image creation utilities
#
#   written by Jason Baker (jason@onejasonforsale.com)
#   project's github: https://github.com/codercowboy/freedosbootdisks
#   more info: http://www.codercowboy.com
#
#################################################################################
#
# UPDATES:
# 
# 2018/10/19
# - Remove MacOS dot files from created disk
# - Add support for 180K, 360K, 640K, 1200K disk sizes
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
	echo "      Supported boot disk file sizes: 1.4MB, 1200K, 720K, 640K, 360K, 320K, 180K, and 160K."
	echo "  CREATE_ALL_BOOT_DISKS - create all supported boot disks in build/bootdisks folder."
	echo "  CREATE_ALL_BOOT_DISKS [VOLUME LABEL] - create all supported boot disks in build/bootdisks folder with specified Volume Label."
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
	echo "  CREATE BOOT_SECTOR [FILE] - creates a 1.4MB FreeDOS .img boot sector."
	echo "  CREATE BOOT_SECTOR [SECTOR SIZE] [SECTOR COUNT] [FILE] - create boot sector with given sector specifications"
	echo "  CREATE BOOT_SECTOR [SIZE] [FILE] - create boot sector with specified standard diskette size"
	echo "      Supported boot disk sizes: 1.4MB, 1200K, 720K, 640K, 360K, 320K, 180K, and 160K."
	echo "  CREATE_ALL_BOOT_SECTORS - create all supported boot sectors in build/bootsectors folder."
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
	debug_log "change_boot_sector_property mode: ${1}, value: ${2}, file: ${3}"
	HEX_BYTES=$(convert_number_to_hex "${2}")
	debug_log "change_boot_sector_property value hex bytes: ${HEX_BYTES}"
	# if only one byte is in number ie 0x01, change it to 0x0001
	if [ ${#HEX_BYTES} -eq 4 ]; then
		HEX_BYTES=`echo -n ${HEX_BYTES} | sed 's/0x/0x00/'`
		debug_log "change_boot_sector_property value hex bytes after padding: ${HEX_BYTES}"
	fi
	HEX_BYTES_REVERSED=$(reverse_hex_order "${HEX_BYTES}")	
	debug_log "change_boot_sector_property value hex bytes reversed: ${HEX_BYTES_REVERSED}"
	DECIMAL_ADDRESS=""
	if [ "SECTOR_SIZE" = "${1}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x0B")
		debug_log "change_boot_sector_property sector size write address '${DECIMAL_ADDRESS} (converted from '0x0B')"
	elif [ "SECTOR_COUNT" = "${1}" ]; then
		DECIMAL_ADDRESS=$(convert_hex_to_number "0x13")
		debug_log "change_boot_sector_property sector count write address '${DECIMAL_ADDRESS} (converted from '0x13')"
	else
		print_usage "Unsupported 'CHANGE' mode: ${ACTION}"
	fi
	debug_log "change_boot_sector_property writing value: ${HEX_BYTES_REVERSED} to address: ${DECIMAL_ADDRESS} in file: ${3}"
	replace_bytes "${DECIMAL_ADDRESS}" "${HEX_BYTES_REVERSED}" "${3}"
}

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"
BUILD_HOME="${SCRIPT_HOME}/../build"
SOURCE_BOOT_DISK="${SCRIPT_HOME}/lib/v86.freedos.boot.disk.img"

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

	debug_log "Mode SHOW extracting sector size (this is always fetched in show mode)"
	DECIMAL_ADDRESS=$(convert_hex_to_number "0x0B")
	SECTOR_SIZE=`extract_reversed_number_from_file "${DECIMAL_ADDRESS}" 2 "${FILE}"`
	debug_log "Mode SHOW extracting sector count (this is always fetched in show mode)"
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

	VOLUME_LABEL="";
	if [ "BOOT_DISK" = "${ACTION}" ]; then
		VOLUME_LABEL="${1}"
		if [ -z "${VOLUME_LABEL}" ]; then #TODO: check for valid volume label here too
			print_usage "Invalid volume label: ${VOLUME_LABEL}"
		fi
		shift
	fi
	
	FORMAT=1440
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

	# more formats are listed here: https://en.wikipedia.org/wiki/List_of_floppy_disk_formats
	# the newfs_msdos command's man page (man newfs_msdos) lists a few more supported file sizes too

	if [ "1.4MB" = "${FILE_SIZE}" ]; then
		FORMAT=1440
	elif [ "1200K" = "${FILE_SIZE}" ]; then
		FORMAT=1200	
	elif [ "720K" = "${FILE_SIZE}" ]; then
		FORMAT=720
	elif [ "640K" = "${FILE_SIZE}" ]; then
		FORMAT=640
	elif [ "360K" = "${FILE_SIZE}" ]; then
		FORMAT=360
	elif [ "320K" = "${FILE_SIZE}" ]; then
		FORMAT=320
	elif [ "180K" = "${FILE_SIZE}" ]; then
		FORMAT=180
	elif [ "160K" = "${FILE_SIZE}" ]; then
		FORMAT=160
	else
		print_usage "Unsupported 'CREATE' mode file size: '${FILE_SIZE}', supported sizes are: 1.4MB, 1200K, 720K, 640K, 360K, 320K, 180K, and 160K."
	fi

	SECTOR_COUNT=$((FORMAT * 2))	

	# copy the source v86 boot sector to a tmp file
	debug_log "Creating temp boot sector: ${TMP_BOOT_SECTOR}"
	mkdir -p "${BUILD_HOME}"
	TMP_BOOT_SECTOR="${BUILD_HOME}/bootsector.tmp"
	dd if="${SOURCE_BOOT_DISK}" of="${TMP_BOOT_SECTOR}" bs=512 count=1

	#fix the sector size and count in the boot sector
	change_boot_sector_property SECTOR_SIZE "${SECTOR_SIZE}" "${TMP_BOOT_SECTOR}"
	change_boot_sector_property SECTOR_COUNT "${SECTOR_COUNT}" "${TMP_BOOT_SECTOR}"

	# NOTE: probable bug here, we're not setting correct cylinder/head count on various formats
	# see: https://en.wikipedia.org/wiki/List_of_floppy_disk_formats

	# from: https://apple.stackexchange.com/questions/338718/creating-bootable-freedos-dos-floppy-diskette-img-file-for-v86-on-osx
	if [ "BOOT_DISK" = "${ACTION}" ]; then
		echo "Creating ${FILE_SIZE} FreeDOS boot disk with ${SECTOR_COUNT} sectors, sector size is ${SECTOR_SIZE}, file: ${FILE}"

		# create an empty img file with all zeros in it
		dd if=/dev/zero of="${FILE}" bs=${SECTOR_SIZE} count=${SECTOR_COUNT}		

		# format the floppy image as FAT12
		newfs_msdos -B "${TMP_BOOT_SECTOR}" -v "${VOLUME_LABEL}" -f ${FORMAT} -b 1024 -S ${SECTOR_SIZE} -r 1 -F 12 "${FILE}"

		# mount our target .img file we just created, it'll mount as /Volumes/${VOLUME_LABEL}, copy our minimal files to it
		echo "Copying boot disk contents from ${SCRIPT_HOME}/lib/boot_disk_contents"
		hdiutil attach "${FILE}"
		cp -r "${SCRIPT_HOME}/lib/boot_disk_contents/" "/Volumes/${VOLUME_LABEL}"
		# remove dot files
		find "/Volumes/${VOLUME_LABEL}" -name "._*" -delete
		rm -Rf "/Volumes/${VOLUME_LABEL}/.fseventsd/"
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
elif [ "CREATE_ALL_BOOT_DISKS" = "${OPERATION}" ]; then
	VOLUME_LABEL="FREEDOS";
	if [ ! -z "${ACTION}" ]; then
		VOLUME_LABEL="${ACTION}"
	fi
	BUILD_FOLDER="${BUILD_HOME}/bootdisks"
	mkdir -p "${BUILD_FOLDER}"
	echo "Creating standard FreeDOS boot disks in folder: ${BUILD_FOLDER}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.1.4MB.img"
	echo "Creating 1.4MB FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 1.4MB "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.1200K.img"
	echo "Creating 1200K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 1200K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.720K.img"
	echo "Creating 720K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 720K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.640K.img"
	echo "Creating 640K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 640K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.360K.img"
	echo "Creating 360K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 360K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.320K.img"
	echo "Creating 320K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 320K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.180K.img"
	echo "Creating 180K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 180K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.disk.160K.img"
	echo "Creating 160K FreeDOS boot disk with volume label '${VOLUME_LABEL}': ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_DISK "${VOLUME_LABEL}" 160K "${FILE}"

	echo "Finished creating standard FreeDOS boot disks."
elif [ "CREATE_ALL_BOOT_SECTORS" = "${OPERATION}" ]; then
	BUILD_FOLDER="${BUILD_HOME}/bootsectors"
	mkdir -p "${BUILD_FOLDER}"

	echo "Creating standard FreeDOS boot sectors in folder: ${BUILD_FOLDER}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.1.4MB.img"
	echo "Creating 1.4M FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 1.4MB "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.1200K.img"
	echo "Creating 1200K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 1200K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.720K.img"
	echo "Creating 720K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 720K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.640K.img"
	echo "Creating 640K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 640K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.360K.img"
	echo "Creating 360K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 360K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.320K.img"
	echo "Creating 320K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 320K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.180K.img"
	echo "Creating 180K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 180K "${FILE}"

	FILE="${BUILD_FOLDER}/freedos.boot.sector.160K.img"
	echo "Creating 160K FreeDOS boot sector: ${FILE}"
	"${SCRIPT_HOME}/eddosboot.sh" CREATE BOOT_SECTOR 160K "${FILE}"

	echo "Finished creating standard FreeDOS boot sectors."
else
	print_usage "Unsupported operation: ${OPERATION}"
fi
