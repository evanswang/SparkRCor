# SparkRCor
This is how to use SparkRCor to calculate correlation matrix. The demo input data come from a NFS folder shared by all nodes.

# Prerequisite
## Linux (tested in Ubuntu 18.04.2)
cat

csvtool

split

spark-2.3.3-bin-hadoop2.7

nfs-common

python3

R fields package (optional for Euclidean distance computation only)

## Environment variables
Please change the environment variables for your own OpenStack environment in the file config. The example config file is based on FCA (eta version) in Wellcome Trust Sanger Institute. The SPARKRCOR_HOME and input parameters in the config file should be set to your local path in .bashrc or .bash_profile. Or, you can set SPARKRCOR_HOME and source the $SPARKRCOR_HOME/config.

## NFS server
To deploy your own Spark Cluster, you need a NFS server that can be mounted by the OpenStack VMs(virtual machines). The best NFS server is a memory based FS, such as tmpfs.

# Client VM
Manually start a client VM in OpenStack and mount the NFS server to the client. Git clone this project to the client VM and set the environment variables in the client VM.

# Quick Start
## Deploy Spark Cluster
``` sh
${SPARKRCOR_HOME}/bin/deploy/run.sh
```

## Start correlation calculation job
``` sh
${SPARKRCOR_HOME}/bin/run.sh
```

The result matrix is stored in the file ${RES}/res_final.
