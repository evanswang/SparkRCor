#!/bin/bash

export IN_FILE=/nfs/data/$1row.csv
export OUT_FILE=/nfs/results/$1row.csv
R CMD BATCH /nfs/SparkRCor/vanilla/vanilla.R
