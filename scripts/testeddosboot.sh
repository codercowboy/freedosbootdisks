#!/bin/bash

#TODO: put license, desc, email, warning about osx here

DEBUG_HEXLIB="true"

SCRIPT_HOME="`dirname ${BASH_SOURCE[0]}`"

source "${SCRIPT_HOME}/hexlib.sh"

SOURCE_BOOT_DISK="${SCRIPT_HOME}/../lib/v86.freedos.boot.disk.img"
TEST_BOOT_SECTOR="${SCRIPT_HOME}/test.boot.sector.img"
TEST_BOOT_DISK="${SCRIPT_HOME}/test.boot.disk.img"

debug_log "SOURCE_BOOT_DISK: ${SOURCE_BOOT_DISK}"
debug_log "TEST_BOOT_SECTOR: ${TEST_BOOT_SECTOR}"
debug_log "TEST_BOOT_DISK: ${TEST_BOOT_DISK}"

if [ -f "${TEST_BOOT_SECTOR}" ]; then
	rm "${TEST_BOOT_SECTOR}"
fi

if [ ! -f "${SOURCE_BOOT_DISK}" ]; then
	echo "ERROR: source freedos boot disk image is missing: ${SOURCE_BOOT_DISK}"
	exit 1
fi

RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${SOURCE_BOOT_DISK}")
verify_test "Test 1.a" "512" "${RESULT}"

RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${SOURCE_BOOT_DISK}")
verify_test "Test 1.b" "1440" "${RESULT}"

# test boot sector extraction
${SCRIPT_HOME}/eddosboot.sh DEBUG COPY_BOOT_SECTOR "${SOURCE_BOOT_DISK}" "${TEST_BOOT_SECTOR}"
if [ ! -f "${TEST_BOOT_SECTOR}" ]; then
	echo "Test 2.a failure, test disk wasn't copied: ${TEST_BOOT_SECTOR}"
	exit 1
fi
echo "Test 2.a SUCCESS: test boot sector was copied."
# from: https://unix.stackexchange.com/questions/16640/how-can-i-get-the-size-of-a-file-in-a-bash-script
FILE_SIZE=$(stat -f%z "${TEST_BOOT_SECTOR}")
if [ ! "512" = "${FILE_SIZE}" ]; then
	echo "Test 2.b failure, test boot sector size isn't 512 bytes, it's: ${FILE_SIZE}"
	exit 1
fi
echo "Test 2.b SUCCESS: test boot sector is 512 bytes."
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 2.c" "512" "${RESULT}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${TEST_BOOT_SECTOR}")
verify_test "Test 2.d" "1440" "${RESULT}"

# test changing sector info on test boot sector
${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_SIZE 512 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 3.a" "512" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_SIZE 1024 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 3.b" "1024" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_SIZE 1 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 3.c" "1" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_SIZE 512 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 3.d" "512" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_SIZE 19 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_SECTOR}")
verify_test "Test 3.e" "19" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_COUNT 1200 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${TEST_BOOT_SECTOR}")
verify_test "Test 4.a" "1200" "${RESULT}"

${SCRIPT_HOME}/eddosboot.sh DEBUG CHANGE SECTOR_COUNT 5 "${TEST_BOOT_SECTOR}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${TEST_BOOT_SECTOR}")
verify_test "Test 4.b" "5" "${RESULT}"

# test copying boot sector
cp "${SOURCE_BOOT_DISK}" "${TEST_BOOT_DISK}"

SOURCE_FILE_SIZE=$(stat -f%z "${SOURCE_BOOT_DISK}")
TARGET_FILE_SIZE=$(stat -f%z "${TEST_BOOT_DISK}")
if [ ! "${SOURCE_FILE_SIZE}" = "${TARGET_FILE_SIZE}" ]; then
	echo "Test 5.a failure: copied file is not correct size after boot sector copy, should be: ${SOURCE_FILE_SIZE}, but is: ${TARGET_FILE_SIZE}"
	exit 1
fi
echo "Test 5.a passed: copied file is correct size."

${SCRIPT_HOME}/eddosboot.sh DEBUG COPY_BOOT_SECTOR "${TEST_BOOT_SECTOR}" "${TEST_BOOT_DISK}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_DISK}")
verify_test "Test 5.b" "19" "${RESULT}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${TEST_BOOT_DISK}")
verify_test "Test 5.c" "5" "${RESULT}"
TARGET_FILE_SIZE=$(stat -f%z "${TEST_BOOT_DISK}")
if [ ! "${SOURCE_FILE_SIZE}" = "${TARGET_FILE_SIZE}" ]; then
	echo "Test 5.d failure: copied file is not correct size after boot sector copy, should be: ${SOURCE_FILE_SIZE}, but is: ${TARGET_FILE_SIZE}"
	exit 1
fi
echo "Test 5.d passed: copied file is correct size after boot sector copy"

${SCRIPT_HOME}/eddosboot.sh DEBUG COPY_BOOT_SECTOR "${SOURCE_BOOT_DISK}" "${TEST_BOOT_DISK}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_SIZE "${TEST_BOOT_DISK}")
verify_test "Test 6.a" "512" "${RESULT}"
RESULT=$(${SCRIPT_HOME}/eddosboot.sh DEBUG SHOW SECTOR_COUNT "${TEST_BOOT_DISK}")
verify_test "Test 6.b" "1440" "${RESULT}"
TARGET_FILE_SIZE=$(stat -f%z "${TEST_BOOT_DISK}")
if [ ! "${SOURCE_FILE_SIZE}" = "${TARGET_FILE_SIZE}" ]; then
	echo "Test 6.c failure: copied file is not correct size after boot sector copy, should be: ${SOURCE_FILE_SIZE}, but is: ${TARGET_FILE_SIZE}"
	exit 1
fi
echo "Test 5.a passed: copied file is correct size after boot sector copy"

# in this case, we are copying to a new file that doesn't exist, it should only be 512 bytes


rm "${TEST_BOOT_SECTOR}"

echo ""
echo "All Tests Passed!"

exit 0

print_usage_x() {
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [FILE] - creates a 1.4MB FreeDOS boot disk"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SECTOR COUNT] [SECTOR SIZE] [FILE] - creates boot disk w/ given sector specifications"
	echo "  CREATE BOOT_DISK [VOLUME LABEL] [SIZE] [FILE] - creates a boot disk with specified file size"
	echo "      Supported boot disk file sizes: 160K 320K 720K 1.4MB"
	echo ""
	echo "  Example Usage: CREATE_BOOT_DISK MYDISK 720K disk.img"
	echo ""
	echo "  Example above would create a 720K FreeDOS boot disk in the disk.img file with the volume label of MYDISK."
	echo ""
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
}