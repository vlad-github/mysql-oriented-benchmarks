#!/bin/bash

#echo "Estimated time: 10-20 minutes"

mkdir -p ./results/cpu

#CPU multi thread
time for i in 1 2 4 6 8 12 16 24 32 48 64 96 128 192 256 320 512 ; do echo "CPU threads: $i" ; sysbench cpu --threads=$i --cpu-max-prime=30000 --events=10000000 --max-time=100 run > ./results/cpu/cpu_$i.txt ; done


