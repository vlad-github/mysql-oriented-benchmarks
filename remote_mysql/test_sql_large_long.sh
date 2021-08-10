#!/bin/bash

MYSQL_USER=sbtest
MYSQL_PASS=sbtest
MYSQL_HOST=$1
MYSQL_DATABASE=sbtest

THREADS="1 2 4 6 8 10 12 16 20 24 32 48 64 96 128 160 192 256 320 384 448 512"
TABLES=64
PREPARE_THREADS=20
SIZE=10000000
TARGET_DIR=./results/sql_long


#yum install sysbench
#apt-get update
#apt-get install sysbench
#sysbench 1.0.20

#CREATE DATABASE sbtest;
#CREATE USER sbtest@localhost IDENTIFIED BY 'sbtest';
#GRANT ALL PRIVILEGES, SUPER ON *.* TO sbtest@localhost;

mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "SET GLOBAL max_prepared_stmt_count = 524288"
mysql -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "SHOW GLOBAL variables like 'max_prepared_stmt_count'"

mkdir -p $TARGET_DIR/`date +%F`

mv $TARGET_DIR/oltp_*.txt $TARGET_DIR/`date +%F`/

#SBCOUNT=`mysql $MYSQL_DATABASE --user=$MYSQL_USER --password=$MYSQL_PASS -NB -e "select COUNT(*) from sbtest1"`
#mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "DROP DATABASE IF EXISTS sbtest;CREATE DATABASE sbtest;"
#echo "Current table size: $SBCOUNT."

echo "Resetting test data..."
mysql -u $MYSQL_USER --password=$MYSQL_PASS -e "DROP DATABASE IF EXISTS sbtest;CREATE DATABASE sbtest;"
time sysbench --test=/usr/share/sysbench/oltp_point_select.lua prepare \
        --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER --mysql-password=$MYSQL_PASS \
        --tables=$TABLES --table-size=$SIZE --threads=$PREPARE_THREADS > $TARGET_DIR/oltp_prepare.log 2>&1

for t in $THREADS ; do 
        echo -n "RO/treads=$t:\t" ; 
        sysbench --test=/usr/share/sysbench/oltp_point_select.lua run --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER \
                --mysql-password=$MYSQL_PASS --tables=$TABLES --table-size=$SIZE --threads=$t \
                --max-time=300 > $TARGET_DIR/oltp_point_select_"$t".txt ; 
done

for t in $THREADS ; do 
        echo -n "RW/threads=$t:\t" ; 
        sysbench --test=/usr/share/sysbench/oltp_read_write.lua run --mysql-host=$MYSQL_HOST --mysql-user=$MYSQL_USER \
                --mysql-password=$MYSQL_PASS --tables=$TABLES --table-size=$SIZE --threads=$t \
                --max-time=300 > $TARGET_DIR/oltp_read_write_"$t".txt ; 
done
