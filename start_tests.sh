#!/bin/bash

### Getting some general info about the system
mkdir -p ./results/general_info

wget percona.com/get/pt-summary && chmod 755 ./pt-summary
./pt-summary > ./results/general_info/pt-summary.info
# in case we're in AWS
wget -q -O - http://169.254.169.254/latest/meta-data/instance-type > ./results/general_info/aws-instance-type.info

bash ./test_cpu.sh
bash ./test_fileio.sh
bash ./test_mem.sh
bash ./test_sql_inram.sh
# bash ./test_sql_inram_long.sh
bash ./test_sql_large.sh
# bash ./test_sql_large_long.sh
