# SparkRCor
This is how to use SparkRCor to calculate correlation matrix. The demo input data come from a NFS folder shared by all nodes.

# Prerequisite
## Linux (tested in Ubuntu 18.04.2)
cat
csvtool
split
spark-2.3.3-bin-hadoop2.7
nfs

# Environment variables
The SPARKRCOR_HOME should be set to your local path in .bashrc or .bash_profile. All the other input parameters are stored in the config file.