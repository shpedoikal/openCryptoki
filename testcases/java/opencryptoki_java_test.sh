#!/bin/bash
#
# java sign/verify testing script
#
# The caller of this script should know that it only works on tokens that will allow a public
# key to be imported
#
# The purpose of this script is to:
# 1. query a token to see what mechanisms it supports and run the test once per mechanism
# 2. generate a java PKCS11 config file (see run_test) to point java to the API .so
#
# Kent Yoder <yoder1@us.ibm.com>
#

GLOBAL_RC=0
LIBRARY_PATH=${exec_prefix}/lib/opencryptoki/libopencryptoki.so
CFG_FILE=opencryptoki_java.cfg

NUM_MECHS=5
MECHS[0]="CKM_SHA1_RSA_PKCS"
MECHS[1]="CKM_MD5_RSA_PKCS"
MECHS[2]="CKM_SHA256_RSA_PKCS"
MECHS[3]="CKM_SHA384_RSA_PKCS"
MECHS[4]="CKM_SHA512_RSA_PKCS"
#MECHS[5]="CKM_ECDSA_SHA1"

# usage: run_test <mechanism> <slot id>
function run_test
{
	echo "name=Sample" > $CFG_FILE
	echo "slot=$2" >> $CFG_FILE
	echo "library=$LIBRARY_PATH" >> $CFG_FILE

	## generate a software key, sign with it, verify using p11
	## generate a p11 key, sign with it, verify using openssl
	java opencryptoki_java_test $1 $CFG_FILE
}

#set -x

#
# main()
#
SLOT_ID=0
NOSTOP=0

#
# Check for -slot, -nostop params
#
while test "x$1" != "x"; do
	if test "x$1" == "x-slot"; then
		if test "x$2" != "x"; then
			shift
			SLOT_ID=$1
			shift
			continue
		else
			usage $0
		fi
	elif test "x$1" == "x-nostop"; then
		shift
		NOSTOP=1
	else
		usage $0
	fi
done

# for each mechanism
for i in $(seq 0 $(( $NUM_MECHS - 1)))
do
	pkcsconf -c $SLOT_ID -m | grep ${MECHS[i]}
	if test $? -eq 0; then
		run_test ${MECHS[i]} $SLOT_ID
	fi

done

exit $GLOBAL_RC
