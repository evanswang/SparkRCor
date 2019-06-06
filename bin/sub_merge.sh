#!/bin/bash
###################################################################################
# Name : merge
# Author: sw23
# Date: 1 Jun 2019
# Function : merge result sub-matrices.
###################################################################################

source ${SPARKRCOR_HOME}/config

# 51s

for((j=0;j<$((${NODE_NUM}));j++))
do
  cat ${RES}/block_$1_${j} >> ${RES}/block_$1
done

csvtool transpose ${RES}/block_$1 > ${RES}/res_$1

echo $1

date
