#!/bin/bash
###################################################################################
# Name : merge
# Author: sw23
# Date: 1 Jun 2019
# Function : merge result sub-matrices.
###################################################################################

source ${SPARKRCOR_HOME}/config

for((i=0;i<$((${NODE_NUM}));i++))
do
  for((j=0;j<$((${NODE_NUM}));j++))
  do
    ln -s ${RES}/block_${i}_${j} ${RES}/block_${j}_${i} 
  done
done

for((i=0;i<$((${NODE_NUM}));i++))
do
  #for((j=0;j<$((${NODE_NUM}));j++))
  #do
  #  cat ${RES}/block_${i}_${j} >> ${RES}/block_${i}
  #done
  ${SPARKRCOR_HOME}/bin/sub_merge.sh ${i} &
done

#for((i=0;i<$((${NODE_NUM}));i++))
#do
#  csvtool transpose ${RES}/block_${i} > ${RES}/res_${i}
#done

while true; do
	PNUM=`ps aux | grep sub_merge | wc -l`
	if [ ${PNUM} -lt 2 ]; then
		break;
	fi
done

rm -f ${RES}/block*

for((i=0;i<$((${NODE_NUM}));i++))
do
  cat ${RES}/res_${i} >> ${RES}/res
done

head -n ${SAMPLE_NUM} ${RES}/res > ${RES}/res_tmp

rm -f ${RES}/res

csvtool setcolumns ${SAMPLE_NUM} ${RES}/res_tmp > ${RES}/res

rm -f ${RES}/res_tmp
