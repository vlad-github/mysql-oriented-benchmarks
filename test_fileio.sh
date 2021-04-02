#!/bin/bash

echo -n "Preparing test files..."

mkdir -p ./results/fileio
mkdir -p ./io_testfiles
cd ./io_testfiles

#if [[ ! -e test_file.1 ]] ; then
#        echo "FileIO test data not detected, running prepare"
#        time sysbench --test=fileio --file-total-size=20G prepare > ../results/fileio/fileio_prepare.log 2>&1
#else
#        echo "$SBCOUNT: OK, fileIO prepare already completed"
#fi

### force prepare for clean tests
echo "starting tests " >> ../results/fileio/fileio_prepare.log
time sysbench --test=fileio --file-total-size=120G prepare >> ../results/fileio/fileio_prepare.log 2>&1

echo "Running tests"

for m in seqrd rndrd seqwr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ; do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t".txt ; 
done ; done

# seqwr + fsync
for m in seqwr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ; do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t --file-fsync-freq=1 run > ../results/fileio/sysbench_fileio_"$m"_"$t"_fsync.txt ; 
done ; done

time sysbench --test=fileio --file-total-size=120G prepare >> ../results/fileio/fileio_prepare.log 2>&1

# rndwr / fsync=0
for m in rndwr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ; do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t --file-fsync-freq=0 run > ../results/fileio/sysbench_fileio_"$m"_"$t".txt ; 
done ; done

# rndwr / fsync=1
for m in rndwr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;       do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t --file-fsync-freq=1 run > ../results/fileio/sysbench_fileio_"$m"_"$t"_fsync.txt ; 
done ; done

# seqrewr / block = 16384
for m in seqrewr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;     do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t".txt ; 
done ; done

# seqrewr / block = 4096
for m in seqrewr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;     do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-block-size=4096 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_4k.txt ; 
done ; done

# seqrewr / block = 16384, nodirect
for m in seqrewr ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;     do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-block-size=16384 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_16k_nodirect.txt ; 
done ; done

# direct / rw ratio = 4
for m in rndrw ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;       do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-rw-ratio=4 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_direct_rw4.txt ; 
done ; done

# direct / rw ratio = 4
for m in rndrw ; do for t in 1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512 ;       do echo "Test: $m threads: $t" ; 
    echo 3 > /proc/sys/vm/drop_caches
    sysbench --test=fileio --file-io-mode=sync --file-total-size=120G --file-extra-flags=direct --file-rw-ratio=4 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_direct_rw4.txt ; 
done ; done
