#!/bin/bash
# This is just a benchmark baseline for performance test, not part of the SparkRCor pipeline.

for((i=1000;i<10001;i=i+1000))
do
	echo $i
	rm -fr /nfs/data/*
	cp /mnt/data/${i}row.csv /nfs/data/
	time ssh spark1 /nfs/SparkRCor/vanilla/remote.sh $i
	rm -fr /nfs/results/*
done
