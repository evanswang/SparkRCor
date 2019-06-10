#!/bin/bash

date

source ${SPARKRCOR_HOME}/config

# clean result and tmp files
rm -fr ${TMP}
rm -fr ${RES}
mkdir -p ${TMP}
mkdir -p ${RES}

rm -fr ${TMP}/prepare.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/prepare.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/prepare.sh
echo '${SPARKRCOR_HOME}/bin/prepare.sh' >> ${TMP}/prepare.sh
chmod +x ${TMP}/prepare.sh
time ssh spark1 ${TMP}/prepare.sh

# run sh in the master node (spark1)
rm -fr ${TMP}/run.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/run.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/run.sh
echo "/opt/spark-2.3.3-bin-hadoop2.7/bin/spark-submit /nfs/SparkRCor/R/spark.R --master spark://spark1:7077" >> ${TMP}/run.sh
chmod +x ${TMP}/run.sh
ssh spark1 ${TMP}/run.sh

rm -fr ${TMP}/block*

rm -fr ${TMP}/merge.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/merge.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/merge.sh
echo '${SPARKRCOR_HOME}/bin/merge.sh' >> ${TMP}/merge.sh
chmod +x ${TMP}/merge.sh
time ssh spark1 ${TMP}/merge.sh

date