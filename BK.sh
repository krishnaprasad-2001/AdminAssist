#!/bin/bash

source /root/AdminAssist/db.sh
wp_url="https://wordpress.org/latest.zip"
main() {
	if grep -q "wp-blog-header.php" index.php 
	then
		installation="wp";
	fi
	case "$installation" in
		wp)
			case "$1" in
				deb)
					check_debug;
					;;
				tdeb)
					toggle_debug;
					;;
				db)
					wp_db;
					;;
				upgrade)
					wp_upgrade;
					;;
				plugin)
					wp_plugin;
					;;
				theme)
					wp_theme;
					;;
				fix_db)
					fix_db;
					;;
				*)
					check_wp;
					;;
			esac
			;;
		*)
			echo "❌ Unknown module: $1"
			;;
	esac
}
check_debug(){
	LINE=$(grep "define( 'WP_DEBUG'" wp-config.php)
	if echo "$LINE" | grep -q "true"; then
		echo "✅ Debug mode is now ENABLED"
	else
		echo "❌ Debug mode is now DISABLED"
	fi
}
toggle_debug(){
	line=$(cat -n wp-config.php|grep "define( 'WP_DEBUG'" |awk '{print $1}')
	LINE=$(grep "define( 'WP_DEBUG'" wp-config.php)
	if echo "$LINE" | grep -q "true"; then
		echo "✅ Debug mode was ENABLED"
		sed -i "$line s/true/false/g" wp-config.php
	else
		echo "❌ Debug mode was DISABLED"
		sed -i "$line s/false/true/g" wp-config.php
	fi
	check_debug
	(grep "define( 'WP_DEBUG'" wp-config.php)
}
check_wp(){
	if grep -q "wp-blog-header.php" index.php 
	then
		 echo "Wordpress installation found"
		 grep "wp_version" wp-includes/version.php |grep -v "global"
		 # headerlocation=$(grep -i blog-header.php index.php |grep require |cut -d\' -f2 )
		 # if [ $headerlocation = "/wp-blog-header.php" ]
		 # then
			 # echo "wordpress in default location"
		 # else
			# loc=$(grep -i blog-header.php index.php |grep require |cut -d\' -f2  |cut -d"/" -f2 ) 
			# if [ loc = "wp-blog-header.php" ]
			# then
			#
			# else
				# directory_installation=$loc;
			# fi
		 # fi
	fi
}
check_file(){
	if [ -e index.php ]
	then
		main "$@"
	else
		echo "index file not found"
	fi
}

check_cpanel(){
	if [ -e /etc/trueuserdomains ]
	then
		return 0;
	else
		echo "Not a cPanel server"
	fi
}
details(){
	user=$(pwd| awk -F'/' '{print $3}')
	if grep -q $user /etc/trueuserdomains
	then
		domain=$(grep $user /etc/trueuserdomains |cut -d: -f1)
		echo "$user $domain"
	else
		echo "user not found"
		exit 0
	fi
}
init(){
	case "$1" in
		apache)
			check_cpanel
			read user domain < <(details);
			echo "user :$user"
			echo "domain :$domain"
			if [[ -z $domain || -z $user ]];
			then
				echo "domain or user not found"
				exit 0;
			fi
			grep $domain /usr/local/apache/logs/error_log |less
			;;
		wpinstall)
			wp_install;
		;;
		--h)
			get_help;
		;;
		*)
			main "$@"
		;;
	esac
}
wp_upgrade(){
	wget -p $wp_url;
	read user domain < <(details);
	if [[ -e index.php ]]
	then
		rm -rf wordpress
	fi
	unzip -q wordpress.org/latest.zip
	#rsync -avz --quiet --inplace wordpress/wp-includes/* wp-includes/
	#rsync -avz --quiet --inplace wordpress/wp-admin/* wp-admin/
	mv -n wordpress/wp-includes wp-includes
	mv -n wordpress/wp-admin wp-admin
	rm -rf wordpress.org
	chown -R $user. wp-includes
	chown -R $user. wp-admin
}
wp_plugin(){
	plugind=$(find . -type d -name plugins |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "plugin in $plugind"
	ls -al $plugind
}
wp_theme(){
	themed=$(find . -type d -name themes |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "theme in $themed"
	ls -al $themed
}
wp_install(){
	wget -p $wp_url;
	read user domain < <(details);
	if [[ -e index.php ]]
	then
		rm -rf wordpress
	fi
	unzip -q wordpress.org/latest.zip
	#rsync -avz --quiet --inplace wordpress/wp-includes/* wp-includes/
	#rsync -avz --quiet --inplace wordpress/wp-admin/* wp-admin/
	mv -n wordpress/*
	rm -rf wordpress.org
	chown -R $user. * 
}

get_help(){
	echo "deb -> to get the status of the debug mode 
	tdeb -> toggle debug mode 
	db -> Get the database details 
	upgrade -> Upgrade the wordpress installation 
	theme -> list out the themes in wordpress 
	fix_db -> fix database connectivity error 
	apache -> displays the apache error logs"
}

init "$@"
