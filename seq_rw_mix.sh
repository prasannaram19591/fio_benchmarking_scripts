#!/bin/bash

rm -f seqrwmix_report.csv

calc(){ awk "BEGIN { print "$*" }"; }

for bs in `cat block_size.csv`
do
  for ds in `cat data_size.csv`
  do
    for tr in `cat threads.csv`
    do
      for rpr in `cat percentage.csv`
      do
        wpr=`calc 100-$rpr`
        echo Running sequential fio job on a $ds size of data with $bs block size having $tr threads for $rpr percent read and $wpr percent write..

        FIOCMD=`echo fio --name=seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr --rw=rw --rwmixread=$rpr --direct=1 --ioengine=libaio --bs=$bs --numjobs=$tr --size=$ds --iodepth=64 --group_reporting`

        fio --name=seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr --rw=rw --rwmixread=$rpr --direct=1 --ioengine=libaio --bs=$bs --numjobs=$tr --size=$ds --iodepth=64 --group_reporting > seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt

        RIOPS=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}'`
        WIOPS=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}'`

        RIOPSUNIT=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 1-1`

        if [ "$RIOPSUNIT" == "k" ]; then
                RIOPS=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 2-7 | rev`
                RIOPS=`calc $RIOPS*1000`
        elif [ "$RIOPSUNIT" == "m" ]; then
                RIOPS=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 2-7 | rev`
                RIOPS=`calc $RIOPS*1000000`
        fi

        WIOPSUNIT=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 1-1`

        if [ "$WIOPSUNIT" == "k" ]; then
                WIOPS=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 2-7 | rev`
                WIOPS=`calc $WIOPS*1000`
        elif [ "$RIOPSUNIT" == "m" ]; then
                WIOPS=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep IOPS | awk -F "=" '{ print $2 }' | awk -F "," '{ print $1}' | rev | cut -b 2-7 | rev`
                WIOPS=`calc $WIOPS*1000000`
        fi

        RBWPS=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep BW | awk -F "=" '{ print $3 }' | awk '{ print $1 }' | rev | cut -b 6-12 | rev`
        WBWPS=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep BW | awk -F "=" '{ print $3 }' | awk '{ print $1 }' | rev | cut -b 6-12 | rev`

        RBWUNIT=`grep -w read seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep BW | awk -F "=" '{ print $3 }' | awk '{ print $1 }' | rev | cut -b 1-5 | rev`

        if [ "$RBWUNIT" == "KiB/s" ]; then
                RBWPS=`calc $RBWPS/1024`
        fi

        WBWUNIT=`grep -w write seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep BW | awk -F "=" '{ print $3 }' | awk '{ print $1 }' | rev | cut -b 1-5 | rev`

        if [ "$WBWUNIT" == "KiB/s" ]; then
                WBWPS=`calc $WBWPS/1024`
        fi

        RLAT=`grep lat seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep -vE 'slat|clat' | grep min | awk '{print $5}' | awk -F "=" '{print $NF}' | sed 's/,//g' | head -n 1`
        WLAT=`grep lat seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep -vE 'slat|clat' | grep min | awk '{print $5}' | awk -F "=" '{print $NF}' | sed 's/,//g' | tail -n 1`
        
        RLATUNIT=`grep lat seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep -vE 'slat|clat' | grep min | awk '{print $2}' | sed 's/[():]//g' | head -n 1`

        if [ "$RLATUNIT" == "usec" ]; then
                RLAT=`calc $RLAT/1000`
        fi

        WLATUNIT=`grep lat seqrwmix-r-$rpr-w-$wpr-bs-$bs-ds-$ds-tr-$tr.txt | grep -vE 'slat|clat' | grep min | awk '{print $2}' | sed 's/[():]//g' | tail -n 1`

        if [ "$WLATUNIT" == "usec" ]; then
                WLAT=`calc $WLAT/1000`
        fi
        
        echo $rpr,$wpr,$bs,$ds,$tr,$RIOPS,$RBWPS,$RLAT,$WIOPS,$WBWPS,$WLAT,$FIOCMD >> seqrwmix_report.csv
        rm -f seqrwmix-r-*-w-*-bs-*-ds-*-tr-*.*.0
      done
      echo >> seqrwmix_report.csv
    done
  done
done

sed -i '1iRead_perc,Write_perc,Block_size,Data_size,Threads,Read_IOPS,Read_BW(MB),Read_Lat(ms),Write_IOPS,Write_BW(MB),Write_Lat(ms),FIO_Commands' seqrwmix_report.csv
