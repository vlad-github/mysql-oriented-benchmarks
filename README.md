### The Goal:
Perform MySQL oriented hardware and SQL benchmarks using syntetic tests provided by SysBench to get a sense of how MySQL may act and compare different hardware, VDS and MySQL configuration.

### !!! Safety warning !!!
Script is intended to stress out your system to find saturation point on varios parts like CPU, memory and disk (IO).

PLEASE DO NOT RUN THIS ON LIVE PRODUCTION BOXES.

### General tips
You need the following to run these scripts 
- sysbench 1.0
- MySQL installed, configured and running
- Free 146Gb+ on MySQL data partirtion (+additinal 130Gb for binary logs if they are enabled)
- Free 20Gb+ on the partition where this script is installed for fileIO testing
- Idle box with no load to avoid interference with benhcmarks. For example virtual sever which is running on hardware with other loaded VDS boxes is not the best place to run the benchmarks.
For the boxes with more than 140Gb innodb buffer pool, script will benchmark in-memory database speed

### These scripts requires SysBench installed 
On CentOS do: 
```
  yum install sysbench
```  
On Debian / Ubuntu do:
```
  apt-get update
  apt-get install sysbench
```
### MySQL credentials 
User sbtest and database sbtest required to run the tests. 

Please do the following on MySQL side before running the scripts:
```
  CREATE DATABASE sbtest;
  GRANT ALL PRIVILEGES ON *.* TO sbtest@localhost IDENTIFIED BY 'sbtest';
```

### MySQL configuration notes
Please review your MySQL confuration. Usual settings are as follows:
- innodb_buffer_pool_size is approx 80% of dedicated MySQL instance
- log_bin (binary logging) is enabled if you plan to have replcas
- binlog_format=MIXED & binlog_row_image=MINIMAL
- slow_query_log=OFF
- max_connections is at least 512

If you need any help with MySQL cluster sizing - please feel free to send me a note via http://astellar.com/contact-me/
