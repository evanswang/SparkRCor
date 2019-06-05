# SparkRCor
This is how to use SparkRCor to calculate correlation matrix. The demo input data come from a NFS folder shared by all nodes.

# Prerequisite
## Linux (tested in Ubuntu 18.04.2)
cat
csvtool
split
spark-2.3.3-bin-hadoop2.7
nfs
python3

# Environment variables
The SPARKRCOR_HOME and input parameters in the config file should be set to your local path in .bashrc or .bash_profile.