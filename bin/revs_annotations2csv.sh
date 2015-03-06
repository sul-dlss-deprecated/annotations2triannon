#!/bin/bash
#===============================================================================
#
#          FILE:  revs_annotations2csv.sh
# 
#         USAGE:  ./revs_annotations2csv.sh 
# 
#   DESCRIPTION:  
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Darren L. Weber, Ph.D. (), darren.weber@stanford.edu
#       COMPANY:  Stanford University
#       VERSION:  1.0
#       CREATED:  02/04/2015 02:24:13 PM PST
#      REVISION:  ---
#===============================================================================

source .env
# .env should export: 
#export REVS_SRC_USER - user with login privilege on REVS_SRC_HOST
#export REVS_SRC_HOST - REVS_SRC_HOST should have access to REVS mysql db
# There should be a script in $REVS_SRC_USER@$REVS_SRC_HOST:~/revs_annotations_dump.sh
# That script should dump mysql tables into $REVS_SRC_USER@$REVS_SRC_HOST:~/revs_annotations.sql
# These ssh/scp connections may rely on Kerberos authentication.
ssh ${REVS_SRC_USER}@${REVS_SRC_HOST} '~/revs_annotations_dump.sh'
scp ${REVS_SRC_USER}@${REVS_SRC_HOST}:~/revs_annotations.sql .

sleep 1
if [ ! -s revs_annotations.sql ]; then 
    echo 'failed to dump and retrieve revs_annotations.sql'
    exit 1
fi

# assumes the 'revs' db has been created and the current
# shell $USER has required privileges to run SQL in revs_annotations.sql,
# such as DROP/CREATE/LOCK table, INSERT etc.  Also note that the
# $USER must have a MySQL password stored in ~/.mysql_pass
pass4mysql=$(cat ~/.mysql_pass)
mysql --user=$USER --password=${pass4mysql} revs < revs_annotations.sql
if [ $? -ne 0 ]; then echo 'failed to import revs_annotations.sql'; exit 1; fi
echo "Imported revs annotations into local MySQL db."

out_path='/tmp/revs'

mkdir -p $out_path
if [ $? -ne 0 ]; then echo "failed to create ${out_path}"; exit 1; fi

chmod a+rwx /tmp/revs
if [ $? -ne 0 ]; then echo "failed to chmod  ${out_path}"; exit 1; fi

# Assumes the $USER has FILE permission, i.e.
# GRANT FILE ON *.* TO 'USER'@'localhost';
mysqldump --tab="${out_path}" \
    --fields-enclosed-by="'" \
    --fields-terminated-by=';' \
    --fields-escaped-by='"' \
    --lines-terminated-by='\n' \
    --user=$USER --password=${pass4mysql} revs annotations users

if [ $? -ne 0 ]; then echo 'failed to export revs to CSV'; exit 1; fi
echo "Exported revs annotations to CSV files at ${out_path}: "
ls -lh /tmp/revs/

