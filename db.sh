#!/bin/bash
wp_db(){
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
