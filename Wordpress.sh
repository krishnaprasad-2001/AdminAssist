# backupPostfix to take the details on the instance the script was invoked 
# This can be later used to rename the existing installation without conflict
backupPostfix=$(date |tr " " _ |tr : _)
BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/log.sh"
source "$BASE_DIR/Debug.sh"

wordpress(){
	case "$1" in
		deb) 
			check_debug; # check the debug mode in the installation 
			;;
		tdeb)
			toggle_debug; # Toggle the debug mode in the installation 

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
}

# The function to upgrade the wordpress version prestnt in the domain
wp_upgrade(){
	flog
	wget -p $wp_url;
	read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
	if [[ -e index.php ]]
	then
		rm -rf wordpress
	fi
	unzip -q wordpress.org/latest.zip
	#rsync -avz --quiet --inplace wordpress/wp-includes/* wp-includes/
	#rsync -avz --quiet --inplace wordpress/wp-admin/* wp-admin/
	execute mv -n wordpress/wp-includes wp-includes
	execute mv -n wordpress/wp-admin wp-admin
	execute rm -rf wordpress.org
	execute chown -R $user. wp-includes
	execute chown -R $user. wp-admin
}

# Lists out the plugins in the installation (Good for debugging)
wp_plugin(){
	flog
	plugind=$(find . -type d -name plugins |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "plugin in $plugind"
	ls -al $plugind
}

# Lists out the themes in the installation 
wp_theme(){
	flog
	themed=$(find . -type d -name themes |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "theme in $themed"
	ls -al $themed
}

# Code for installing wordpress without UI
wp_install(){
	flog
	if [ -e wordpress ]
	then 
		if [ -d wordpress ]
		then 
			echo "Existing installation found"
			read -p "should we proceed with the installation (\"click y or Y to proceed\"): "
			REPLY=$(echo "$REPLY" | xargs)
			if [[ $REPLY = "y" || $REPLY = "Y" ]]
			then
				execute mkdir -p wordpress_$(echo "$backupPostfix")
				execute mv wordpress/* wordpress_$(echo "$backupPostfix")
				if [ $? -ne 0 ]
				then
					echo "something went wrong with the moving"
				# 	exit 0;
				fi

				echo "=============================" 
				du -sch wordpress_$(echo "$backupPostfix") |grep wordpress
				echo "=============================" 
				# move_with_progress wordpress/* wordpress_$(echo "$backupPostfix")
				# move_with_progress wordpress wordpress_$(echo "$backupPostfix")
				echo "existing installation moved to wordpress_$(echo $backupPostfix)"
			else
				echo "Skipping installation"
				exit 1;
			fi
		fi
	fi

	# Added the lightgreen progress Bar in the black BG, which is much cooler
	echo -ne "$BG_BLACK"
	echo -ne "$LIGHT_GREEN"
	echo "Downloading latest version"
	wget -p --quiet --show-progress $wp_url 
	echo -ne "$NC"
	read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
	if [[ -e index.php ]]
	then
		execute rm -rf wordpress
	fi
	execute unzip -qo wordpress.org/latest.zip
	execute rm -rf wordpress.org
	if [[ $user != "NoCpanel" ]]
	then
		execute chown -R $user. * 
	fi
}

# print and toggle the debut status and finally calls the check_debug function to print the status after the toggle 
toggle_debug(){
	flog
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
# check and print  the debug status 
check_debug(){
	flog
	LINE=$(grep "define( 'WP_DEBUG'" wp-config.php)
	if echo "$LINE" | grep -q "true"; then
		echo "✅ Debug mode is now ENABLED"
	else
		echo "❌ Debug mode is now DISABLED"
	fi
}
wp_db(){
	flog
	if [ -e wp-config.php ]
	then
		echo "Database details"
		echo "==================="
		less wp-config.php|egrep 'DB_USER|DB_NAME|DB_PASSWORD|DB_HOST|\$table_prefix'
		echo "==================="
	else
		echo "configuration file not found"
		return 0;
	fi
}
fix_db(){
	flog
	user=$(less wp-config.php |grep DB_USER |cut -d, -f2| grep -oP "'\K[^']+(?=')");
	database=$(less wp-config.php |grep DB_NAME |cut -d, -f2| grep -oP "'\K[^']+(?=')");
	echo "Database user=$user" 
	echo "Database name=$database"
	mysql -e "GRANT ALL PRIVILEGES ON $user.* TO '$database'@'localhost';"
	read -p "Do you want to reset the password with the configuration file"
	reply=$REPLY
	if [[ reply = "y" ]]
	then
		password=$(less wp-config.php |grep DB_PASSWOR |cut -d, -f2| grep -oP "'\K[^']+(?=')");
		mysql -e "ALTER USER $user@localhost IDENTIFIED BY ;"
		if [[ $? -eq 0 ]] 
		then 
			echo "successfull"
		else 
			echo "failed"
		fi
			
	else
		echo "Database password not changed"
	fi
}


# Cleanup function to ensure that the stuff dont break and also clean up the unwanted files. 
# You can edit this to suit your needs
cleanup(){
	flog
	echo
	echo -ne "$RED"
	echo "Cancelling installation and cleaning up"
	execute rm -rf latest.zip 
	execute rm -rf wordpress.org
	exit 4;
}


# Trap flag to ensure that the clearnup function is called (Normally caled with the installation or upgrade processs)
trap cleanup SIGINT
