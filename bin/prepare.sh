#!/bin/bash
###################################################################################
# Name : Prepare data for the SparkRCor calculation.
# Author: sw23
# Date: 5 Jun 2019
# Function : This is the data preparation script that should be launched by the
# run.sh script automatically. Please do not run this independently, if not in
# purpose.
###################################################################################

# load the config file
source ${SPARKRCOR_HOME}/config

# double check the virtual worker number
# and input file
echo ${NODE_NUM}
echo ${INPUT}

# split data by virtual worker number
split -d -l ${BLOCK_SIZE} ${INPUT} ${TMP}/block_

# rename block_0* to block_* to make the index easier
for((i=0;i<10;i++))
do
	mv ${TMP}/block_0${i} ${TMP}/block_${i}
done

# NOTE: The data splitting is not always even.
# To make the calculation easier to split,
# we fill the last few blocks with random
# data to make sure the block num is the
# same as the virtual worker number and
# all blocks have the same size.

# The last data block
FILE_INDEX=$((${NODE_NUM} - 1))
LAST_FILE="${TMP}/block_${FILE_INDEX}"

# if the last few blocks do not exist,
# copy the block_0 to fill them.
while [ true ]
do
	if [ -f "${LAST_FILE}" ]; then
    	echo "find the last block file"
    	break
	fi
	cp ${TMP}/block_0 ${LAST_FILE}
	FILE_INDEX=$((${FILE_INDEX} - 1))
	LAST_FILE="${TMP}/block_${FILE_INDEX}"
done

# if the last block is smaller than the others,
# fill it with some random double data.
FIRST_NUM=`wc -l ${TMP}/block_0 | awk '{print $1}'`
LAST_NUM=`wc -l ${LAST_FILE} | awk '{print $1}'`
DIFF_NUM=$((${FIRST_NUM} - ${LAST_NUM}))
head -n ${DIFF_NUM} ${TMP}/block_0 >> ${LAST_FILE}
