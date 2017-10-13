######################################
# 
# 脚本名称: helper.sh
#
# 功能:
#    SPI功能辅助类
#  
# 注意事项：
#     使用source包含         
# 
# 作者: chenxuelin@emicnet.com
#    
######################################


# ----------------------------
# 结束运行函数
# ----------------------------
terminate(){
    local msg="SPI控制程序已终止"
    print_log "$msg" "info" 
    exit 1
}

# ----------------------------
# 检查运行环境函数
# ----------------------------
checkEnv(){
    return 0；
}
# ----------------------------
# 安装系统环境
# ----------------------------
installEnv(){
	local status=0
	print_log "正在安装系统软件" "info"
	
	print_log "准备安装ubuntu静默安装工具debconf-utils" "info"
	check_and_install_soft debconf-utils && status=0 || status=1
	if [ $status -gt 0 ]; then
		print_log "安装debconf-utils失败,退出程序，请手工安装debconf-utils，再次运行此脚本" "error"
		exit 4
	else
		print_log "设置静默安装参数" info
		# todo修改mysql的密码	
		cp "$_bin_dir/res/debparam.conf" "$_bin_dir/res/debparam_bak.conf" 
		sed -i "s/MYSQLROOTPASS/$mysql_root_pass/g" "$_bin_dir/res/debparam_bak.conf" 
		debconf-set-selections "$_bin_dir/res/debparam_bak.conf"
		rm "$_bin_dir/res/debparam_bak.conf"
	fi
	print_log "安装debconf-utils已完成" info
	
	print_log "准备安装进程管理工具supervisor" "info"
	check_and_install_soft supervisor && status=0 || status=1
	print_log "安装supervisor已完成" info
	
	# 安装mysql
	print_log "准备安装mysql" "info"
	if [ $install_mysql -gt 0 ]; then	
		check_and_install_soft mysql-server
		print_log "安装mysql已完成" info
	else
		print_log "未配置安装mysql，跳过安装" warn
	fi
	
	# 安装nginx
	print_log "准备安装nginx" "info"
	if [ $install_nginx -gt 0 ]; then	
		check_and_install_soft nginx
		print_log "安装nginx已完成" info
	else
		print_log "未配置安装nginx，跳过安装" warn
	fi
	
	# 安装redis
	print_log "准备安装redis" "info"
	if [ $install_redis -gt 0 ]; then	
		check_and_install_soft redis-server
		print_log "安装redis已完成" info
	else
		print_log "未配置安装redis，跳过安装" warn
	fi
	
	# 安装apache
	print_log "准备安装apache" "info"
	if [ $install_apache -gt 0 ]; then	
		check_and_install_soft apache2
		print_log "安装apache已完成" info
		print_log "停止apache模块mpm_event,mpm_prefork,打开mpm_worker,rewrite,proxy_fcgi" info
		a2dismod mpm_event
		a2dismod mpm_prefork
		a2enmod mpm_worker rewrite proxy_fcgi
		# 安装php7.0
		print_log "准备安装php7.0" "info"
		check_and_install_soft php7.0 && status=0 || status=1
		if [ $status != 0 ]; then
			print_log "php7.0安装失败，跳过安装依赖库" "error"
		else
			print_log "准备安装php7.0依赖库" "info"
			check_and_install_soft php7.0-curl
			check_and_install_soft php7.0-mbstring
			check_and_install_soft php7.0-gd
			check_and_install_soft php7.0-mysql
			check_and_install_soft php-redis
			check_and_install_soft mcrypt
			check_and_install_soft libmcrypt-dev
			check_and_install_soft php-mcrypt
			#check_and_install_soft libapache2-mod-fastcgi
			print_log "停止apache模块php7.0，启用php7.0-fpm配置文件" info
			a2dismod php7.0
			a2enconf php7.0-fpm
		fi
	else
		print_log "未配置安装apache，跳过安装" warn
	fi
}

# ----------------------------
# 删除环境
# ----------------------------
clearEnv(){
	local status=0
	print_log "正在卸载系统软件" "info"
	
	print_log "准备卸载supervisor" "info"
	check_and_remove_soft supervisor
	print_log "卸载supervisor已完成" "info"
	
	print_log "准备卸载php7.0相关软件" "info"
	# 先删除依赖mysql，apache的包，mcrypt和libmcrypt-dev是系统包，不删除
	check_and_remove_soft libapache2-mod-php7.0
	check_and_remove_soft libapache2-mod-fastcgi
	check_and_remove_soft php7.0-mysql
	check_and_remove_soft php-common && status=0 || status=1
	print_log "卸载php7.0已完成" "info"
	if [ $status = 0 ]; then print_log "删除php7.0配置文件" "info" ; rm /etc/php -rf; fi

	check_and_remove_soft apache2 && status=0 || status=1
	if [ $status = 0 ]; then print_log "删除apache2配置文件" "info" ; rm /etc/apache2 -rf; fi
	print_log "卸载apache2已完成" "info"
	
	check_and_remove_soft nginx-common && status=0 || status=1
	if [ $status = 0 ]; then print_log "删除nginx配置文件" "info" ; rm /etc/nginx -rf; fi
	print_log "卸载nginx已完成" "info"
	
	check_and_remove_soft mysql-server && status=0 || status=1	
	if [ $status = 0 ]; then		
		print_log "删除mysql配置文件和库文件" "info"
		# 删除配置文件
		rm /etc/mysql -rf 
		# 删除库文件
		rm /var/lib/mysql -rf
	fi
	print_log "卸载mysql已完成" "info"
	
	check_and_remove_soft redis-server && status=0 || status=1
	if [ $status = 0 ]; then print_log "删除redis配置文件" "info" ; rm /etc/redis -rf; fi
	print_log "卸载redis-server已完成" "info"
	
}
# ----------------------------
# 配置环境
# ----------------------------
configSPI(){
	if [ $install_nginx -gt 0 ]; then	configNginx; fi
	if [ $install_apache -gt 0 ]; then	configApache; fi
	if [ $install_mysql -gt 0 ]; then	 configSpiSys; fi
}
# ----------------------------
# 配置nginx环境
# ----------------------------
configNginx(){
	print_log "开始配置nginx" info
	is_install "nginx" && status=0 || status=1
	if [ $status != 0 ]; then print_log "未安装nginx"; return 1; fi
	print_log "删除缺省配置文件：default" "warn"
	rm /etc/nginx/sites-enabled/default -rf
	rm /etc/nginx/sites-enabled/nginx_ssl.conf  -rf
	
	print_log "检查冲突配置文件，如果存在先删除" info
	for confFile in `ls /etc/nginx/sites-enabled/`
	do
	    file="/etc/nginx/sites-enabled/$confFile"
		grep "*:$nginx_public_port" $file >/dev/null && status=0 || status=1
		if [ $status = 0 ]; then print_log "删除冲突配置文件：$file" "warn" ; rm $file -rf;  fi
	done
	
	print_log "拷贝res/nginx_ssl.conf到nginx配置目录：/etc/nginx/sites-available/nginx_ssl.conf" info
	cp "$_bin_dir/res/nginx_ssl.conf" /etc/nginx/sites-available/ -f	
	
	print_log "配置nginx发布文件：/etc/nginx/sites-available/nginx_ssl.conf" info
	nginxproxypass=''
    for server in `echo "$nginx_proxy_addr"|sed "s/,/ /g"`
    do
    	if [ -z "$nginxproxypass" ] ; then
    		nginxproxypass="server $server weight=1;"
    	else
    		nginxproxypass="$nginxproxypass\nserver $server weight=1;"
    	fi
    done
    sed -i "s/NGINXPROXYPASSADDR/$nginxproxypass/g" /etc/nginx/sites-available/nginx_ssl.conf
    sed -i "s/NGINXPUBLISHPORT/$nginx_https_port/g" /etc/nginx/sites-available/nginx_ssl.conf
    sed -i "s#NGINXSSLCRT#$_bin_dir/crt/nginx/server.crt#g" /etc/nginx/sites-available/nginx_ssl.conf
    sed -i "s#NGINXSSLPRIVATEKEY#$_bin_dir/crt/nginx/server.key#g" /etc/nginx/sites-available/nginx_ssl.conf
    
	print_log "建立发布link文件：/etc/nginx/sites-enabled/nginx_ssl.conf" info
	ln -s /etc/nginx/sites-available/nginx_ssl.conf /etc/nginx/sites-enabled/nginx_ssl.conf
	
	print_log "重启nginx" info
	service nginx restart
}
# ----------------------------
# 配置apache环境
# ----------------------------
configApache(){
	print_log "开始配置apache" info
	is_install "apache2" && status=0 || status=1
	if [ $status != 0 ]; then print_log "未安装apache"; return 1; fi
	# 修改ports.conf,加入监听端口
	print_log "屏蔽80和443端口" info
	sed -i -r "s/Listen\s(443|80)$/#&/" /etc/apache2/ports.conf
	
	cat "/etc/apache2/ports.conf" | grep "Listen $apache_publish_port" > /dev/null && status=0 || status=1
	if [ $status != 0 ]
	then
	    print_log "添加apache监听端口：$apache_publish_port" info
		echo "Listen $apache_publish_port" >>/etc/apache2/ports.conf
	fi
	
	print_log "删除缺省配置文件：000-default.conf,apache.conf" "warn"
	rm /etc/apache2/sites-enabled/000-default.conf -rf
	rm /etc/apache2/sites-enabled/apache.conf  -rf
	
	print_log "检查冲突配置文件，如果存在先删除" info
	for confFile in `ls /etc/apache2/sites-enabled/`
	do
	    file="/etc/apache2/sites-enabled/$confFile"
		grep "*:$apache_publish_port" $file >/dev/null && status=0 || status=1
		if [ $status = 0 ]; then 
		    print_log "删除冲突配置文件：$file" info
			rm $file -rf; 
		fi
	done
	
	print_log "拷贝apache新配置文件：/etc/apache2/sites-enabled/apache.conf" info
	cp "$_bin_dir/res/apache.conf" /etc/apache2/sites-available/ -f	
    
    print_log "配置apache发布文件：/etc/apache2/sites-available/apache.conf" info
    sed -i "s/APACHEPUBLISHPORT/$apache_publish_port/g" /etc/apache2/sites-available/apache.conf
    sed -i "s#APACHEPUBLISHDIR#$_project_dir/public#g" /etc/apache2/sites-available/apache.conf
    
	print_log "建立发布link文件：/etc/apache2/sites-enabled/apache.conf" info
	ln -s /etc/apache2/sites-available/apache.conf /etc/apache2/sites-enabled/apache.conf 
    
    print_log "配置php参数文件：/etc/php/7.0/apache2/php.ini" info
    sed -ri 's/.*(session.save_handler.*=).*/\1user/' /etc/php/7.0/fpm/php.ini
    
    # 修改所有文件用户为www-data
    print_log "赋予目前权限：$_project_dir" info
    chown www-data:www-data $_project_dir -R
    chmod 777 $_project_dir -R
   
    #重启apache
    print_log "重启apache" info
    service apache2 restart
}
# ----------------------------
# 配置SPI系统环境
# ----------------------------
configSpiSys(){
     print_log "配置SPI参数：$_project_dir/application/config.php" info
     if [ -z $redis_uri ] ; then
	 	sed -ri "s/('host'.*=>).*/\1'$redis_uri',/"  "$_project_dir/application/config.php"
	 fi
	 print_log "配置SPI数据库参数：$_project_dir/application/database.php" info
	 sed -ri "s/('hostname'.*=>).*/\1'$mysql_host',/" "$_project_dir/application/database.php"
	 sed -ri "s/('username'.*=>).*/\1'$mysql_user',/" "$_project_dir/application/database.php"
	 #处理mysql_pwd中的特殊字符
	 #local newMysqlPwd=${mysql_pass//&/\\&}
	 sed -ri "s/('password'.*=>).*/\1'$mysql_pass',/" "$_project_dir/application/database.php"
	 sed -ri "s/('hostport'.*=>).*/\1'$mysql_port',/" "$_project_dir/application/database.php"
}
# ----------------------------
# 查看SPI系统环境
# ----------------------------
spiInfo(){
	print_log "功能还未实现" info
}
# ----------------------------
# 配置apache环境
# ----------------------------
spiPublic(){
	configApache
}
# ----------------------------
# 启动spi系统环境
# ----------------------------
spiStart(){
	print_log "重启apache" info
    service apache2 restart
}
# ----------------------------
# 停止spi系统环境
# ----------------------------
spiStop(){
	print_log "停止apache" info
    service apache2 stop
}
# ----------------------------
# 重新加载spi系统环境
# ----------------------------
spiReload(){
	print_log "重启apache" info
    service apache2 restart
}
getGlobalConfig(){
	if [ ! -f "$db_config_file" ]
	then
	   print_log "未找到数据库配置文件：$db_config_file" "warn"
	else
		eval $(cat $db_config_file |sed "s#//# #g" | sed "s/=/ /g" | awk  '{if(NF>1){printf("%s=\"%s\";",$1,$2)}}')
		if [ -z $DB_HOST ]
		then
			print_log "未找到DB_HOST" "warn"
		else
			mysql_host=`echo "$DB_HOST" | awk -F ',' '{print $1}'`
		fi
		if [ -z $DB_PORT ]
		then
			print_log "未找到DB_PORT" "warn"
		else
			mysql_port=$DB_PORT
		fi
		if [ -z $DB_USER ]
		then
			print_log "未找到DB_USER" "warn"
		else
			mysql_user=$DB_USER
		fi
		if [ -z $DB_PASS ]
		then
			print_log "未找到DB_PASS" "warn"
		else
			mysql_pwd=$DB_PASS
		fi
	fi
	
	#echo "mysql_host:"$mysql_host
	#echo "mysql_port:"$mysql_port
	#echo "mysql_user:"$mysql_user
	#echo "mysql_pwd:"$mysql_pwd
}
