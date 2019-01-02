#!/bin/bash

mkdir -p ./results/memory

time for s in local global ; do 
    for mode in rnd seq ; do 
        for oper in read write ; do 
            for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 192 256 320 512 ; do 
                echo "$s : $mode : $oper, $t threads " ; 
                sysbench memory --memory-block-size=1K --memory-scope=$s --memory-total-size=8G --memory-oper=$oper --memory-access-mode=$mode --threads=$t run > ./results/memory/mem_"$s"_"$mode"_"$oper"_"$t".txt ; 
            done ; 
        done ; 
    done ; 
done
