#!/bin/bash
# This is just a benchmark demo for performance test, not part of the SparkRCor pipeline.

for((k=0;k<3;k++))
do
	for((i=1000;i<10001;i=i+1000))
	do
		for j in 48 64 80
		do
			echo $i $j $k
			####################################
			## reset NFS
			####################################
			#source /mnt/SparkRCor/config
			#echo STOP
			#sudo systemctl stop nfs-kernel-server
			#sleep 1
			#echo UMOUNT
			#sudo umount /nfs
			#sleep 1
			#TMPFS_CODE=1
			#while [ "$TMPFS_CODE" -ne 0 ]
			#do
			#	echo "waiting for nfs umount"
			#	TMPFS_CODE=$((`df | grep nfs | wc -l`))
			#	sleep 1
			#done
			#echo MOUNT
			#sudo mount -t tmpfs -o size=30720M tmpfs /nfs
			#sleep 1
			#echo START
			#sudo systemctl start nfs-kernel-server
			#sleep 1
			#mkdir -p /nfs/data
			#mkdir -p /nfs/tmp
			#mkdir -p /nfs/results
			#cp -fr /mnt/SparkRCor /nfs/
			#source ${SPARKRCOR_HOME}/config
			####################################
			## mount nfs to cluster
			####################################
			#echo NFS CONN
			#for((m=0;m<$((${#HOSTS[@]}));m++))
			#do
			#	ssh ${HOSTS[${m}]} sudo umount /nfs
			#	ssh ${HOSTS[${m}]} sudo mount 192.168.0.21:/nfs /nfs
			#done
			
			mv ${SPARKRCOR_HOME}/config ${SPARKRCOR_HOME}/config.bak
			echo "export NODE_NUM=${j}" >> ${SPARKRCOR_HOME}/config
			echo "export INPUT=/nfs/data/${i}row.csv" >> ${SPARKRCOR_HOME}/config
			echo "export SAMPLE_NUM=${i}" >> ${SPARKRCOR_HOME}/config
			tail -n 47 ${SPARKRCOR_HOME}/config.bak >> ${SPARKRCOR_HOME}/config
			rm -f /nfs/data/*
			cp /mnt/data/${i}row.csv /nfs/data/
			nohup ${SPARKRCOR_HOME}/bin/run.sh > /mnt/logs/test_${i}_${j}_${k}.log
			mv ${SPARKRCOR_HOME}/config.bak ${SPARKRCOR_HOME}/config
		done
	done
done
