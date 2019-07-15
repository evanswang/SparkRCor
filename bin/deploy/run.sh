#!/bin/bash

###################################################################################
# Name : create spark cluster
# Author: sw23
# Date: 13 Mar 2019
# Function : Create a new spark cluster. Please make sure you have enough compute
#            resources, such as CPU, memory and floating ip. The floating ips are
#            stored in the file iplist.txt.
###################################################################################

source ${SPARKRCOR_HOME}/config

PWD=${SPARKRCOR_HOME}/bin/deploy

#HOSTS=(spark1 spark2 spark3 spark4)

###################################
# get token
###################################
${PWD}/get_token.sh
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "get token"
	echo "!!!Error!!!"
	echo
	exit 1
fi

###################################
# read floating ips to IPARRAY
###################################
IFS=$'\r\n' GLOBIGNORE='*' command eval 'IPARRAY=($(cat $PWD/iplist.txt))'
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "IPARRAY"
	echo "!!!Error!!!"
	echo
	exit 1
fi

###################################
# create vms
###################################
rm -fr ${PWD}/vmlist.txt

for((i=0;i<$((${#HOSTS[@]}));i++))
do
	echo ${HOSTS[${i}]}
	${PWD}/create_vm.sh ${HOSTS[${i}]} >> ${PWD}/vmlist.txt
	RET_CODE=$?
	if [ "$RET_CODE" -ne 0 ];
	then
		echo "!!!Error!!!"
		echo "${PWD}/create_vm.sh ${HOSTS[${i}]} >> ${PWD}/vmlist.txt"
		echo "!!!Error!!!"
		echo
		exit 1
	fi
done

###################################
# bind floating ips to fixed ips
###################################

IPID=0

rm -fr ${PWD}/fixed_iplist.txt

for VMID in `cat ${PWD}/vmlist.txt`
do
	echo ${VMID}
	
	FIXED_IP=""
	while [ -z "$FIXED_IP" ]
	do
		echo "waiting for fixed ip"
		FIXED_IP=`${PWD}/get_fixed_ip.sh ${VMID}`
		RET_CODE=$?
		if [ "$RET_CODE" -ne 0 ];
		then
			echo "!!!Error!!!"
			echo "${PWD}/get_fixed_ip.sh ${VMID}"
			echo "!!!Error!!!"
			echo
			exit 1
		fi
		sleep 2
	done
	echo
	echo ${FIXED_IP}
	echo ${FIXED_IP} >> ${PWD}/fixed_iplist.txt
	echo ${IPARRAY[${IPID}]}
	${PWD}/add_floating_ip.sh ${IPARRAY[${IPID}]} ${FIXED_IP} ${VMID}
	RET_CODE=$?
	if [ "$RET_CODE" -ne 0 ];
	then
		echo "!!!Error!!!"
		echo "${PWD}/add_floating_ip.sh ${IPARRAY[${IPID}]} ${FIXED_IP} ${VMID}"
		echo "!!!Error!!!"
		echo
		exit 1
	fi
	IPID=${IPID}+1
	echo
done

###################################
# read fixed ips to FIXED_IP_ARRAY
###################################

IFS=$'\r\n' GLOBIGNORE='*' command eval 'FIXED_IP_ARRAY=($(cat $PWD/fixed_iplist.txt))'
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "IPARRAY"
	echo "!!!Error!!!"
	echo
	exit 1
fi

###################################
# init hostnames and slaves
###################################

for ((i=0;i<${IPID};i++))
do
	# waiting hosts up
	RET_CODE=1
	while [ "$RET_CODE" -ne 0 ]
	do
		echo "waiting for HOST ${IPARRAY[$i]}"
		ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} true
		RET_CODE=$?
		sleep 2
	done
	# change hdfs master host name
	ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} "sed -i 's/spark01/${HOSTS[0]}/g' /opt/hadoop-2.7.3/etc/hadoop/core-site.xml"
	# init /etc/hosts, /opt/hadoop-2.7.3/etc/hadoop/core-site.xml
	for ((j=0;j<${IPID};j++))
	do
		echo "SLAVE "${HOSTS[$i]}
		echo ${FIXED_IP_ARRAY[$j]}
		echo ${HOSTS[$j]}
		echo
		ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} "echo '${FIXED_IP_ARRAY[$j]} ${HOSTS[$j]}' | sudo tee -a /etc/hosts"
		RET_CODE=$?
		if [ "$RET_CODE" -ne 0 ];
		then
			echo "!!!Error!!!"
			echo "init hosts"
			echo "!!!Error!!!"
			echo
			exit 1
		fi
	done
	# init slaves
	for ((j=1;j<${IPID};j++))
	do
		echo "SLAVE "${HOSTS[$i]}
		echo ${FIXED_IP_ARRAY[$j]}
		echo ${HOSTS[$j]}
		echo
		ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} "echo '${HOSTS[$j]}' | tee -a /opt/spark-2.3.3-bin-hadoop2.7/conf/slaves"
		if [ "$RET_CODE" -ne 0 ];
		then
			echo "!!!Error!!!"
			echo "init spark slaves"
			echo "!!!Error!!!"
			echo
			exit 1
		fi
		ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} "echo '${HOSTS[$j]}' | tee -a /opt/hadoop-2.7.3/etc/hadoop/slaves"
		if [ "$RET_CODE" -ne 0 ];
		then
			echo "!!!Error!!!"
			echo "init hadoop slaves"
			echo "!!!Error!!!"
			echo
			exit 1
		fi	
	done
done

###################################
# format HDFS
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/bin/hadoop namenode -format"

###################################
# start HDFS
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/sbin/start-dfs.sh"

###################################
# start master
###################################
ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/spark-2.3.3-bin-hadoop2.7/sbin/start-master.sh"

###################################
# start slaves
###################################
ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/spark-2.3.3-bin-hadoop2.7/sbin/start-slaves.sh"

###################################
# stop slaves
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/spark-2.3.3-bin-hadoop2.7/sbin/stop-slaves.sh"

###################################
# stop master
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/spark-2.3.3-bin-hadoop2.7/sbin/stop-master.sh"

###################################
# stop HDFS
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/sbin/stop-dfs.sh"

###################################
# add host names to client
###################################
IFS=$'\r\n' GLOBIGNORE='*' command eval 'FIXIPARRAY=($(cat $PWD/fixed_iplist.txt))'
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "FIXIPARRAY"
	echo "!!!Error!!!"
	echo
	exit 1
fi

for((i=0;i<$((${#HOSTS[@]}));i++))
do
	echo ${HOSTS[${i}]}
	echo ${FIXIPARRAY[${i}]}
	echo "${FIXIPARRAY[${i}]} ${HOSTS[${i}]}" | sudo tee -a /etc/hosts
	if [ "$RET_CODE" -ne 0 ];then
		echo "!!!Error!!!"
		echo "add host names to client"
		echo "!!!Error!!!"
		echo
		exit 1
	fi
done

###################################
# mount nfs to cluster
###################################
for((i=0;i<$((${#HOSTS[@]}));i++))
do
	ssh ${HOSTS[${i}]} sudo umount /nfs
	ssh ${HOSTS[${i}]} sudo mount ${NFS_SERVER_IP}:/nfs /nfs
	if [ "$RET_CODE" -ne 0 ];then
		echo "!!!Error!!!"
		echo "mount nfs to cluster"
		echo "!!!Error!!!"
		echo
		exit 1
	fi
done


# TODO for image
# 1. remove ip in /etc/hosts
# 2. add .ssh/config to disable known_hosts
# 3. remove slave hostnames in /opt/spark-2.3.3-bin-hadoop2.7/conf
# 4. add SPARK_HOME in .bashrc
# 5. start HDFS - /data 
# 6. remove spark key
# 7. remove slave hostnames in /opt/hadoop-2.7.3/etc/hadoop
# 8. clean /data
# 9. add ssh key to .ssh/
# 10. change client config to connect spark, add hosts to /etc/hosts, add hosts to spark conf
# 11. remove hadoop config to enable nfs
# 12. csvtool and python3
