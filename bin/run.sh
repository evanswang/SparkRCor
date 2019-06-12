#!/bin/bash
###################################################################################
# Name : Main Entrance to the SparkRCor calculation
# Author: sw23
# Date: 5 Jun 2019
# Function : This is the Main Entrance to the SparkRCor calculation. Please make
# sure you have filled the config file correctly, before you run this script.
###################################################################################

# Performance test purpose
date

# load the config file
source ${SPARKRCOR_HOME}/config

# clean result and tmp files
echo Cleaning
rm -fr ${TMP}
rm -fr ${RES}
mkdir -p ${TMP}
mkdir -p ${RES}

# write the data preparation script to
# the NFS TMP folder for the Spark master
# (spark1) to run.
echo Preparing
rm -fr ${TMP}/prepare.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/prepare.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/prepare.sh
echo '${SPARKRCOR_HOME}/bin/prepare.sh' >> ${TMP}/prepare.sh
chmod +x ${TMP}/prepare.sh
time ssh spark1 ${TMP}/prepare.sh

# write the calculation script to
# the NFS TMP folder for the Spark master (spark1).
# run the script in the master node.
echo Running
rm -fr ${TMP}/run.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/run.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/run.sh
echo "/opt/spark-2.3.3-bin-hadoop2.7/bin/spark-submit /nfs/SparkRCor/R/spark.R --master spark://spark1:7077" >> ${TMP}/run.sh
chmod +x ${TMP}/run.sh
ssh spark1 ${TMP}/run.sh

# remove data block files in TMP
# to save space to data merging.
echo Cleaning tmp block
rm -fr ${TMP}/block*

# write the data merging script to
# the NFS TMP folder for the Spark master (spark1).
# run the data merging scrpt in the master.
echo Merging data
rm -fr ${TMP}/merge.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/merge.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/merge.sh
echo '${SPARKRCOR_HOME}/bin/merge.sh' >> ${TMP}/merge.sh
chmod +x ${TMP}/merge.sh
time ssh spark1 ${TMP}/merge.sh

date