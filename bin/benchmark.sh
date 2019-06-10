#!/bin/bash
# This is just a benchmark demo for performance test, not part of the SparkRCor pipeline.

mv ${SPARKRCOR_HOME}/config ${SPARKRCOR_HOME}/config.bak
for((k=0;k<3;k++))
do
	for((i=1000;i<10001;i=i+1000))
	do
		for j in 48 64 80
		do
			echo $i $j $k
			rm ${SPARKRCOR_HOME}/config
			echo "export NODE_NUM=${j}" >> ${SPARKRCOR_HOME}/config
			echo "export INPUT=/nfs/data/${i}row.csv" >> ${SPARKRCOR_HOME}/config
			echo "export SAMPLE_NUM=${i}" >> ${SPARKRCOR_HOME}/config
			tail -n 40 ${SPARKRCOR_HOME}/config.bak >> ${SPARKRCOR_HOME}/config
			rm -f /nfs/data/*
			cp /mnt/data/${i}row.csv /nfs/data/
			nohup ${SPARKRCOR_HOME}/bin/run.sh > /mnt/logs/test_${i}_${j}_${k}.log
		done
	done
done
mv ${SPARKRCOR_HOME}/config.bak ${SPARKRCOR_HOME}/config