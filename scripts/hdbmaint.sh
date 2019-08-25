#!/bin/sh

usage() {
    echo -e "\nRequirements:\n\t./dbmaint.q\n" \
            "\nUsage:\n\tbash hdbmaint.sh <hdb_directory>"
            
    exit 1
}

if [ ! $1 ]; then
    usage
fi

taskset -c 0 q ./dbmaint.q -database `readlink -f $1` -c 2000 2000 <<< '\l hdbmaint.q'
exit 0
