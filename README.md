### The Goal:
MySQL oriented hardware and SQL benchmarks are based on SysBench and allow you to test your hardware and MySQL configuration with syntetic tests provided by SysBench to get a sense of how MySQL may act and compare different hardware, VDS and MySQL configuration.

### !!! Safety warning !!!
Script is intended to stress out your system to find saturation point on varios parts like CPU, memory and disk (IO).

PLEASE DO NOT RUN THIS ON LIVE PRODUCTION BOXES.

### General tips
You need the following to run these scripts 
- sysbench 1.0
- MySQL installed, configured and running
- Free 80Gb+ on MySQL data partirtion 
- Free 20Gb+ on the partition where this script is installed for fileIO testing
- Idle box with no load to avoid interference with benhcmarks. For example virtual sever which is running on hardware with other loaded VDS boxes is not the best place to run the benchmarks.

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
