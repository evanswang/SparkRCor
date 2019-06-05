#!/bin/bash
echo ${SPARKRCOR_HOME}

source ${SPARKRCOR_HOME}/config

echo ${NODE_NUM}
echo ${INPUT}

# split data by virtual worker number
split -d -l ${BLOCK_SIZE} ${INPUT} ${TMP}/block_

# rename block_0* to block_* to make index easier
for((i=0;i<10;i++))
do
	mv ${TMP}/block_0${i} ${TMP}/block_${i}
done

# the last block is smaller than the others. fill it with random double data.
FIRST_NUM=`wc -l ${TMP}/block_0 | awk '{print $1}'`
LAST_NUM=`wc -l ${TMP}/block_$((${NODE_NUM} - 1)) | awk '{print $1}'`
DIFF_NUM=$((${FIRST_NUM} - ${LAST_NUM}))
head -n ${DIFF_NUM} ${TMP}/block_0 >> ${TMP}/block_$((${NODE_NUM} - 1))
