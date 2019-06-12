#!/bin/sh

export BAK_DIR=`date +%F-%H-%M-%S`

echo "Backing up HDB tables prior to maintenance"
echo "HDB Directory: ${1}"
echo "Backup Directory: `dirname ${1}`"

echo "Creating hdbdir_bak/$BAK_DIR"
mkdir -p `dirname ${1}`/hdbdir_bak/$BAK_DIR

cp -r --parents $1/* `dirname ${1}`/hdbdir_bak/$BAK_DIR
echo "Backup complete"

taskset -c 0 q ./dbmaint.q -database `readlink -f $1` <<< '\l hdbmaint.q'
exit 0
