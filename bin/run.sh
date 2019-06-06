#!/bin/bash

source ${SPARKRCOR_HOME}/config

# clean result and tmp files
rm -fr ${TMP}
rm -fr ${RES}
mkdir -p ${TMP}
mkdir -p ${RES}

${SPARKRCOR_HOME}/bin/prepare.sh

#/opt/spark-2.3.3-bin-hadoop2.7/bin/sparkR --master spark://spark1:7077 --packages com.databricks:spark-csv_2.11:1.5.0 --driver-memory 8g --executor-memory 7g  --executor-cores 7

# TODO: write this to a sh and run sh in the master node
rm -fr ${TMP}/run.sh
echo "export SPARKRCOR_HOME=${SPARKRCOR_HOME}" >> ${TMP}/run.sh
echo 'source ${SPARKRCOR_HOME}/config' >> ${TMP}/run.sh
echo "/opt/spark-2.3.3-bin-hadoop2.7/bin/spark-submit /nfs/SparkRCor/R/spark.R --master spark://spark1:7077" >> ${TMP}/run.sh
chmod +x ${TMP}/run.sh

ssh spark1 ${TMP}/run.sh

#/opt/spark-2.3.3-bin-hadoop2.7/bin/spark-submit /nfs/SparkRCor/R/spark.R --master spark://spark1:7077 --packages com.databricks:spark-csv_2.11:1.5.0 --driver-memory 8g --executor-memory 7g  --executor-cores 7

#/opt/spark-2.3.3-bin-hadoop2.7/bin/spark-submit /nfs/SparkRCor/R/spark.R --master spark://spark1:7077 --conf "spark.local.dir=/nfs/tmp" --conf "spark.executor.cores=7" --conf "spark.executor.memory=7g" --conf "spark.cores.max=21" --conf "spark.executor.dir=/nfs/tmp" --conf "spark.executor.extraJavaOptions=-Djava.io.tmpdir=/nfs/tmp" --conf "spark.driver.extraJavaOptions=-Djava.io.tmpdir=/nfs/tmp" --conf "spark.driver.cores=7" --conf "spark.driver.memory=6g" 

#/opt/spark-2.3.3-bin-hadoop2.7/bin/sparkR CMD BATCH /nfs/SparkRCor/R/spark.R --master yarn --driver-memory 6g --executor-memory 6g  --executor-cores 6

${SPARKRCOR_HOME}/bin/merge.sh