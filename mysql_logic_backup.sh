#!/bin/bash
#author: alice
#time:2021/1/19
#function: add crontab job .database logic backup for recovery every day and delete dumpfile 30 day ago。create dir $mysql_backup_dir.
#下面脚本是为了在删除表，删除库，意外删除错误数据情况下快速恢复库的备份。关键脚本是mysqldump+binlog2sql达到恢复任意时间点要求。
source  /etc/profile  
source ~/.bash_profile

mysql_instance=mysql_shop
socket=/tmp/mysql.sock
password=haha
port=3306
user=dump_user
host=localhost
mysql_dump=/bin/mysqldump
mysql_backup_dir=/home/mysql
remaining_day=
date22=`date +%Y%m%d-%H%M%S`
date11=`date '+%F'`

dmpfile=${mysql_backup_dir}/pro-dump-${mysql_instance}-${date22}.sql
dmpfile_gz=${mysql_backup_dir}/pro-dump-${mysql_instance}-${date22}.sql.gz
logfile=${mysql_backup_dir}/pro-dump-${mysql_instance}-${date22}.log
mkdir -p $mysql_backup_dir


execute_command="$mysql_dump  --user=$user  --password=$password --host=$host  --port=$port --log-error=$logfile  --triggers --routines --events  --single-transaction   --set-gtid-purged=on  --hex-blob  --default-character-set=utf8mb4 --master-data=2 --all-databases  > ${dmpfile}"

eval $execute_command

if [ $? != 0   ] ; then 
   echo "`date +'%F %T'` $execute_command " >>$logfile
   echo "`date +'%F %T'` mysqldump backup database ${mysql_instance} fail !" >>$logfile
   exit 1
fi
  grep -E 'Error|error' $logfile  
if [ $? = 0 ] ; then 
   echo "`date +'%F %T'` $execute_command " >>$logfile
   echo "`date +'%F %T'` mysqldump backup database ${mysql_instance} fail !" >>$logfile
   exit 1
else 
   echo "`date +'%F %T'` $execute_command " >>$logfile
   echo "`date +'%F %T'`  mysqldump backup database ${mysql_instance} success!" >>$logfile
fi
#gzip file
gzip $dmpfile
#delete  old backup 
find $mysql_backup_dir  -maxdepth 1 -mtime +${remaining_day} -type f -name "pro-dump*.sql.gz" -exec rm {} \;

