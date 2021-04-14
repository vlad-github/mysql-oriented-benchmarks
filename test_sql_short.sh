#!/bin/bash

### In-RAM-mostly db performance test. Using warmup to pull data disk

MYSQL_USER=sbtest
MYSQL_PASS=sbtest
MYSQL_SOCK=/var/run/mysqld/mysqld.sock
MYSQL_DATABASE=sbtest

TARGET_DIR=./results/sql_ram_ro

THREADS="1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512"
TABLES=64
PREPARE_THREADS=16
SIZE=1000000


#yum install sysbench
#apt-get update
#apt-get install sysbench
#sysbench 1.0.20

#CREATE DATABASE sbtest;
#CREATE USER sbtest@localhost IDENTIFIED BY 'sbtest';
#GRANT ALL PRIVILEGES ON sbtest.* TO sbtest@localhost;
#GRANT SUPER ON *.* TO sbtest@localhost;

echo "Testing OLTP point-select, 64 x 1M row tables with prepare."

mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "SET GLOBAL max_prepared_stmt_count = 524288"
mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "SHOW GLOBAL variables like 'max_prepared_stmt_count'"

mkdir -p $TARGET_DIR/`date +%F`

mv $TARGET_DIR/oltp_*.txt $TARGET_DIR/`date +%F`/

mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "DROP DATABASE IF EXISTS sbtest; CREATE DATABASE sbtest;"
time sysbench --test=/usr/share/sysbench/oltp_point_select.lua prepare \
	--mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS \
        --tables=$TABLES --table-size=$SIZE --threads=$PREPARE_THREADS > $TARGET_DIR/oltp_prepare.log 2>&1
echo "Prepare completed"

echo "Warming up the data: "
time for table in `mysql --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "SHOW TABLES FROM $MYSQL_DATABASE"` ; do
        echo -n "$table " 
        mysql $MYSQL_DATABASE --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "select COUNT(pad) from $table"
done

for t in $THREADS ; do 
        echo -n "RO/treads=$t:\t" ; 
        sysbench --test=/usr/share/sysbench/oltp_point_select.lua run --mysql-socket=$MYSQL_SOCK --mysql-user=$MYSQL_USER \
                --mysql-password=$MYSQL_PASS --tables=$TABLES --table-size=$SIZE --threads=$t \
                --max-time=100 > $TARGET_DIR/oltp_point_select_"$t".txt ; 
        sleep 10 ; 
done
