#!/bin/bash
# This is just a benchmark summary for performance test, not part of the SparkRCor pipeline.

for((k=0;k<3;k++))
do
	for((i=1000;i<10001;i=i+1000))
	do
		for j in 48 64 80
		do
			START=`head -n 1 /mnt/logs/test_${i}_${j}_${k}.log`
			START_TS=`date --date="${START}" +"%s"`
			END=`tail -n 1 /mnt/logs/test_${i}_${j}_${k}.log`
			END_TS=`date --date="${END}" +"%s"`
			echo ${i}_${j}_${k}
			echo $((${END_TS} - ${START_TS}))
			echo
			echo
		done
	done
done