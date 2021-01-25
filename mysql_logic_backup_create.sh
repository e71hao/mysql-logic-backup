usage_str=' 
mysql_logic_backup usage :
  --mysql_dump </you/mysqldump/file>\n
  --host <host-ip>\n
  --user <uaername>\n 
  --password <passwd>\n
  --port 3306\n 
  --mysql_backup_dir <backup dir>\n 
  --remaining_day <interger> 
'
getopt_method(){
ARGS=`getopt -o S:,p:,P:,h:,u:  --long socket:,password:,port:,host:,user:,mysql_dump:,mysql_backup_dir:,remaining_day:,help -n "$0" -- "$@"`
if [ $? != 0 ];then
        echo $usage_str
        exit 1
fi
#重新排列参数顺序
eval set -- "${ARGS}"
#通过shift和while循环处理参数
while :
do
    case $1 in
       -S | --socket)
            socket=$2
            shift
            ;;
        -p | --password)
            password=$2
            shift
            ;;
       -P | --port)
            port=$2
            shift
            ;;
       -h | --host)
            host=$2
            shift
            ;;
       -u | --user)
            user=$2
            shift
            ;;
        --mysql_dump)
            mysql_dump=$2
            shift
            ;;
        --mysql_backup_dir)
            mysql_backup_dir=$2
            shift
            ;;
        --remaining_day)
            remaining_day=$2
            shift
            ;;
        --help)
            ;;
        --)
            shift
            break
            ;;
        *)
            echo -e $usage_str ;
            exit 0
            ;;
    esac
shift
done
}
getopt_method "$@"


[ ! $mysql_instance ] &&  mysql_instance=mysql_shop
[ ! $socket ]  && socket=/tmp/mysql.sock
[ ! $password ] && password=123456
[ ! $port ] && port=3306
[ ! $user ] && user=name
[ ! $host ] && host=localhost
[ ! $mysql_dump ] && mysql_dump=/bin/mysqldump
[ ! $mysql_backup_dir ] && mysql_backup_dir=`dirname $0`/..  &&  mysql_backup_dir=`(cd "$BASEDIR"; pwd)`
[ ! $remaining_date ] && remaining_day=30

 mkdir -p $mysql_backup_dir
if [ $? != 0 ] ; then 
 echo "create dir $mysql_backup_dir fail  " ; exit 1
fi
cd $mysql_backup_dir ;  wget  https://raw.githubusercontent.com/e71hao/mysql-logic-backup/master/mysql_logic_backup.sh
mysql_logic_backup_file=${mysql_backup_dir}/mysql_logic_backup.sh
sed -i 's#^user=.*#user='$user'#g'  $mysql_logic_backup_file
sed -i 's#^password=.*#password='$password'#g'  $mysql_logic_backup_file
sed -i 's#^port=.*#port='$port'#g'  $mysql_logic_backup_file
sed -i 's#^host=.*#host='$host'#g'  $mysql_logic_backup_file
sed -i 's#^socket=.*#socket='$socket'#g'  $mysql_logic_backup_file
sed -i 's#^mysql_instance=.*#mysql_instance='$mysql_instance'#g'  $mysql_logic_backup_file
sed -i 's#^mysql_dump=.*#mysql_dump='$mysql_dump'#g'  $mysql_logic_backup_file
sed -i 's#^mysql_backup_dir=.*#mysql_backup_dir='$mysql_backup_dir'#g'  $mysql_logic_backup_file
sed -i 's#^remaining_day=.*#remaining_day='$remaining_day'#g'  $mysql_logic_backup_file

crontab -l > confi123i ; echo "7 3  * * * $mysql_logic_backup_file" >> confi123i && crontab confi123i && rm -f confi123i


