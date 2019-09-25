#!/bin/sh
taskset -c 0 q ./dbmaint.q $* -c 2000 2000 <<< '\l hdbmaint.q'
exit 0