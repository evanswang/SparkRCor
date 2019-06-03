#!/bin/bash

###################################################################################
# Name : create spark cluster
# Function : create spark cluster
# Author: sw23
# Date: 13 Mar 2019
###################################################################################


PWD=`pwd`

HOSTS=(spark1 spark2 spark3 spark4)

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
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "rm -fr ${PWD}/vmlist.txt"
	echo "!!!Error!!!"
	echo
	exit 1
fi

${PWD}/create_vm.sh ${HOSTS[0]} >> ${PWD}/vmlist.txt
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "${PWD}/create_vm.sh ${HOSTS[0]} >> ${PWD}/vmlist.txt"
	echo "!!!Error!!!"
	echo
	exit 1
fi

${PWD}/create_vm.sh ${HOSTS[1]} >> ${PWD}/vmlist.txt
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "${PWD}/create_vm.sh ${HOSTS[1]} >> ${PWD}/vmlist.txt"
	echo "!!!Error!!!"
	echo
	exit 1
fi

${PWD}/create_vm.sh ${HOSTS[2]} >> ${PWD}/vmlist.txt
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "${PWD}/create_vm.sh ${HOSTS[2]} >> ${PWD}/vmlist.txt"
	echo "!!!Error!!!"
	echo
	exit 1
fi

${PWD}/create_vm.sh ${HOSTS[3]} >> ${PWD}/vmlist.txt
RET_CODE=$?
if [ "$RET_CODE" -ne 0 ];
then
	echo "!!!Error!!!"
	echo "${PWD}/create_vm.sh ${HOSTS[3]} >> ${PWD}/vmlist.txt"
	echo "!!!Error!!!"
	echo
	exit 1
fi


###################################
# bind floating ips to fixed ips
###################################

IPID=0

rm -fr fixed_iplist.txt

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
	echo ${FIXED_IP} >> fixed_iplist.txt
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
# debug setting
# COMMENT BEFORE run.sh
#IPID=2
###################################


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
		ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[$i]} "echo '${HOSTS[$j]}' | tee -a /opt/hadoop-2.7.3/etc/hadoop/slaves"
		if [ "$RET_CODE" -ne 0 ];
		then
			echo "!!!Error!!!"
			echo "init slaves"
			echo "!!!Error!!!"
			echo
			exit 1
		fi	
	done
done

###################################
# format HDFS
###################################
ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/bin/hadoop namenode -format"

###################################
# start HDFS
###################################
ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/sbin/start-dfs.sh"

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
# start master
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/spark-2.3.3-bin-hadoop2.7/sbin/stop-master.sh"

###################################
# stop HDFS
###################################
#ssh -o "StrictHostKeyChecking no" ubuntu@${IPARRAY[0]} "/opt/hadoop-2.7.3/sbin/stop-dfs.sh"

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