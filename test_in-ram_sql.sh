#!/bin/bash

### In-RAM-mostly db performance test. Using warmup to pull data disk

MYSQL_USER=sbtest
MYSQL_PASS=sbtest
MYSQL_SOCK=/var/run/mysqld/mysqld.sock
MYSQL_DATABASE=sbtest

TABLES=64
SIZE=1000000


#yum install sysbench
#apt-get update
#apt-get install sysbench
#sysbench 1.0.20

#CREATE DATABASE sbtest;
#CREATE USER sbtest@localhost IDENTIFIED BY 'sbtest';
#GRANT ALL PRIVILEGES ON sbtest.* TO sbtest@localhost;
#GRANT SUPER ON *.* TO sbtest@localhost;

mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "SET GLOBAL max_prepared_stmt_count = 524288"
mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "SHOW GLOBAL variables like 'max_prepared_stmt_count'"

mkdir -p ./results/sql/`date +%F`

mv ./results/sql/oltp_*.txt ./results/sql/`date +%F`/

mkdir -p ./results/sql

SBCOUNT=`mysql $MYSQL_DATABASE --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "select COUNT(*) from sbtest1"`

mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "DROP DATABASE IF EXISTS sbtest; CREATE DATABASE sbtest;"

if [[ ! "$SBCOUNT" -gt 1 ]] ; then
        echo "Test data not detected, running prepare"
        time sysbench --test=/usr/share/sysbench/oltp_point_select.lua prepare \
                --mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS \
                --tables=$TABLES --table-size=$SIZE --threads=16 > ./results/sql/oltp_prepare.log 2>&1
else
        echo "$SBCOUNT: OK, prepare already completed, warming up data"
        for table in `mysql --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "SHOW TABLES FROM $MYSQL_DATABASE"` ; do
                echo "warming up table $table\n" 
                mysql $MYSQL_DATABASE --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "select COUNT(pad) from $table"
        done
fi

# warmup
sysbench --test=/usr/share/sysbench/oltp_point_select.lua run \
        --mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS \
        --tables=$TABLES --table-size=$SIZE --threads=1 \
        --max-time=100 > ./results/sql/oltp_point_select_cold_run_single_thread.txt 

for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ; do 
        echo -n "RO/treads=$t:\t" ; 
        sysbench --test=/usr/share/sysbench/oltp_point_select.lua run --mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER \
                --mysql-password=$MYSQL_PASS --tables=$TABLES --table-size=$SIZE --threads=$t \
                --max-time=100 > ./results/sql/oltp_point_select_"$t".txt ; 
        sleep 10 ; 
done

for t in 1 2 4 6 8 12 16 24 32 48 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512 ; do 
        echo -n "RW/threads=$t:\t" ; 
        sysbench --test=/usr/share/sysbench/oltp_read_write.lua run --mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER \
                --mysql-password=$MYSQL_PASS --tables=$TABLES --table-size=$SIZE --threads=$t \
                --max-time=100 > ./results/sql/oltp_read_write_"$t".txt ; 
        sleep 10 ; 
done
