#!bin/bash
NUM=559

for((i=0;i<24;i++))
do
  for((j=0;j<24;j++))
  do
    ln -s block_${i}_${j} block_${j}_${i} 
  done
done

for((i=0;i<24;i++))
do
  for((j=0;j<24;j++))
  do
    cat block_${i}_${j} >>  block_${i}
  done
done

for((i=0;i<24;i++))
do
  csvtool transpose block_${i} > res_${i}
done

for((i=0;i<24;i++))
do
  cat res_${i} >> res
done

head -n ${NUM} res > res_tmp

csvtool setcolumns ${NUM} res_tmp > res_final