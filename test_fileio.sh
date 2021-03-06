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
time sysbench --test=fileio --file-total-size=20G prepare >> ../results/fileio/fileio_prepare.log 2>&1

echo "Running tests"

for m in seqrd rndrd seqwr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ; do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t".txt ; 
done ; done

### restoring test tiles after write test
time sysbench --test=fileio --file-total-size=20G prepare >> ../results/fileio/fileio_prepare.log 2>&1

for m in rndwr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ; do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t".txt ; 
done ; done

# rndwr / fsync=1
for m in rndwr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ;       do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-test-mode=$m --time=30 --threads=$t --file-fsync-freq=1 run > ../results/fileio/sysbench_fileio_"$m"_"$t"_fsync.txt ; 
done ; done

# seqrewr / block = 512
for m in seqrewr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ;     do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-block-size=512 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_512.txt ; 
done ; done

# seqrewr / block = 4096
for m in seqrewr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ;     do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-block-size=4096 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_4k.txt ; 
done ; done

# seqrewr / block = 512, nodirect
for m in seqrewr ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ;     do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-block-size=512 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_512_nodirect.txt ; 
done ; done

# direct / rw ratio = 4
# old threads 1 2 4 6 8 12 16 24 32 48 64 98 128 190 256 384 512
for m in rndrw ; do for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ;       do echo "Test: $m threads: $t" ; 
    sysbench --test=fileio --file-io-mode=sync --file-total-size=20G --file-extra-flags=direct --file-rw-ratio=4 --file-test-mode=$m --time=30 --threads=$t run > ../results/fileio/sysbench_fileio_"$m"_"$t"_direct_rw4.txt ; 
done ; done

