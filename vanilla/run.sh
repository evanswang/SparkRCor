for((i=1000;i<40001;i=i+1000))
do
	echo $i
	rm -fr /nfs/data/*
	cp /mnt/data/${i}row.csv /nfs/data/
	time ssh spark1 /nfs/SparkRCor/vanilla/remote.sh $i
	rm -fr /nfs/results/*
done
