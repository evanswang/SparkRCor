#!/bin/bash
###################################################################################
# Name : merge
# Author: sw23
# Date: 1 Jun 2019
# Function : merge result sub-matrices.
###################################################################################

# load the config file
source ${SPARKRCOR_HOME}/config

# create symbolic links for the
# symmetric result data blocks, if
# not existing. Please ignore the
# warning message.
for((i=0;i<$((${NODE_NUM}));i++))
do
  for((j=0;j<$((${NODE_NUM}));j++))
  do
    ln -s ${RES}/block_${i}_${j} ${RES}/block_${j}_${i} 
  done
done

# merge the result blocks by row and
# transpose them in parallel.
for((i=0;i<$((${NODE_NUM}));i++))
do
  ${SPARKRCOR_HOME}/bin/sub_merge.sh ${i} &
done

# waiting for the parallel sub_merge.sh, until
# all of them are finished.
while true; do
	PNUM=`ps aux | grep sub_merge | wc -l`
	if [ ${PNUM} -lt 2 ]; then
		break;
	fi
done

# remove the intermedium result data blocks
# to save some space.
rm -f ${RES}/block*

# merge the transposed result blocks by row
for((i=0;i<$((${NODE_NUM}));i++))
do
  cat ${RES}/res_${i} >> ${RES}/res_raw
done

# remove the random filled sample results by row.
head -n ${SAMPLE_NUM} ${RES}/res_raw > ${RES}/res_tmp

# remove the intermedium result
rm -f ${RES}/res_raw

# remove the random filled sample results by column.
csvtool setcolumns ${SAMPLE_NUM} ${RES}/res_tmp > ${RES}/res

# remove the intermedium result
rm -f ${RES}/res_tmp
