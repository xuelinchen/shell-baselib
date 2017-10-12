#!/bin/bash

######################################
# 
# 脚本名称: test.sh
#
# 描述：测试文件
#
# 作者: chenxuelin@emicnet.com
# 
######################################

# 包含必要文件
. cxl_log
. cxl_system
. cxl_print
. cxl_string
. helper.sh

# 声明脚本变量
_file=$(readlink -f $0)  
_dir=$(dirname $_file)  
_current_user=$(whoami)
#_project_dir=$(dirname $_dir)
_project_dir=$(dirname $(dirname $_dir))
_bin_dir="$_project_dir/bin"

__ScriptVersion="spictl-2017.10.10"  
__ScriptName="test.sh"  
ABSDIR=$(cd "$(dirname "$0")"; pwd)
cxl_log_file="spi.log"

# 检查日志文件
check_log_file

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {  
	cat <<EOT
	
Usage :  ${__ScriptName} [ACTION]  [OPTION] ...  
  spi服务器管理
  
ACTION：
  spi服务器操作
  installEnv  安装服务器依赖软件
  clearEnv  删除服务器依赖软件（自动清除所有依赖软件）
  modify  根据option修改服务器参数
  info  查看信息
  publish  发布SPI系统
  start  启动SPI系统
  stop  停止SPI系统
  reload  重启SPI系统
  
Options：
  相关参数
  -h, --help  显示帮助
  -v, --version  显示脚本版本
  --with-nginx=1  安装nginx（安装时生效）大于0为安装0为不安装，缺省安装
  --with-apache=1  安装apache（安装时生效）大于0为安装0为不安装，缺省安装
  --with-mysql=1  安装mysql（安装时生效）大于0为安装0为不安装，缺省安装
  --with-mysql-user=root  spi系统mysql用户名（安装时生效），缺省root
  --with-mysql-pass=C1oudP8x\&2017  spi系统mysql密码（安装时生效），缺省C1oudP8x&2017
  --with-mysql-root-pass=C1oudP8x\&2017  mysql root密码（安装时生效），缺省C1oudP8x&2017
  --with-redis=1  安装redis（安装时生效）大于0为安装0为不安装，缺省安装
	
EOT
}   

if [ "$#" -eq 0 ]; then usage; exit 1; fi  

is_ubuntu 16.04
if [  "$?" -gt 0 ]; then print_log "当前系统非ubuntu 16.04，此安装程序只在ubuntu16.04上做过测试" "error";exit 2; fi
if [  "$_current_user" != "root" ]; then print_log "需要root用户，当前用户是:$_current_user" "error";exit 3; fi
# define variable
SUPPORTACTION="installEnv clearEnv modify info publish start stop reload"
action="$1"
shift
install_mysql=1
install_nginx=1
install_apache=1
install_redis=1
mysql_user=root
mysql_pass="C1oudP8x&2017"
mysql_root_pass="C1oudP8x&2017"

#eval set -- "--with-mysql-pass 'C1oudP8x\&2017' --"

# parse options
RET=`getopt -o hv --long help,version,with-nginx:,with-apache:,with-mysql:,with-mysql-user:,with-mysql-pass:,with-mysql-root-pass:,with-redis: -n "* ERROR" --  "$@"`
eval set -- "$RET"  
while true; do
	case "$1" in  
		-h | --help ) usage; exit 1;; 
		-v | --version ) print_log "$(basename $0) -- version $__ScriptVersion" "info"; exit 1;;  
		--with-nginx)  install_nginx=$2; shift 2 ;;
		--with-apache)  install_apache=$2; shift 2 ;;
		--with-mysql)  install_mysql=$2; shift 2 ;;
		--with-mysql-user)  mysql_user=$2; shift 2 ;;
		--with-mysql-pass)  mysql_pass="$2"; shift 2 ;;
		--with-mysql-root-pass)  mysql_root_pass="$2"; shift 2 ;;
		--with-redis)  install_redis=$2; shift 2 ;;
		-- ) shift; break ;; 
		* ) print_log "internal error!" "error" ; exit 1 ;;  
	esac
done
# check action
case "$action" in
	"installEnv")
		pretty_title "准备安装系统依赖软件"
		installEnv
	 ;;
	"clearEnv")
		pretty_title "准备卸载系统依赖软件"
		clearEnv
	 ;;
	"modify")
		pretty_title "准备修改系统参数"
		cxl_log "准备修改系统参数"
	 ;;
	"info")
		pretty_title "查看系统参数"
		cxl_log "查看系统参数"
	 ;;
	"publish")
		pretty_title "准备配置SPI系统"
		cxl_log "准备配置SPI系统"
	 ;;
	 "start")
	 	pretty_title "准备启动SPI系统"
		cxl_log "准备启动SPI系统"
	 ;;
	 "stop")
	 	pretty_title "准备停止SPI系统"
		cxl_log "准备停止SPI系统"
	 ;;
	 "reload")
	 	pretty_title "准备重启SPI系统"
		cxl_log "准备重启SPI系统"
	 ;;
	 *)
	 	print_log "不支持此操作：$action" "error"
	 	usage
	 	exit 3
	 ;;
esac
exit 0
