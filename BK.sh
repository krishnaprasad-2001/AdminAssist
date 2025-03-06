#!/bin/bash

# sourcing the file containing the Tools for database coloring and other configuration
source configuration.conf
source /root/AdminAssist/db.sh
source ansi_colors.sh

# Wordpress latest version to use for upgrade
wp_url="https://wordpress.org/latest.zip"

# main function 
main() {
	if grep -q "wp-blog-header.php" index.php  # checking for the wp-blog-header reference in the index file(to confirm the installation kind)
	then
		installation="wp";
	fi
	case "$installation" in
		wp)
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
			;;
		*)
			echo "❌ Unknown module: $1"
			;;
	esac
}

# check and print  the debug status 
check_debug(){
	LINE=$(grep "define( 'WP_DEBUG'" wp-config.php)
	if echo "$LINE" | grep -q "true"; then
		echo "✅ Debug mode is now ENABLED"
	else
		echo "❌ Debug mode is now DISABLED"
	fi
}

# print and toggle the debut status and finally calls the check_debug function to print the status after the toggle 
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

# check if installation is wordpress
check_wp(){
	if grep -q "wp-blog-header.php" index.php 
	then
		 echo "Wordpress installation found"
		 grep "wp_version" wp-includes/version.php |grep -v "global"

		 # PS, the below find may be used as a boilerplate template to implement a function that could check for the installation directory
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

# Initially check for the index file itself and only proceed with the main function if the index file is present
check_file(){
	if [ -e index.php ]
	then
		main "$@"
	else
		echo "index file not found"
	fi
}


# check if the server is a cPanel server or not ( if not, the implementaion could differ)
check_cpanel(){
	if [ -e /etc/trueuserdomains ]
	then
		return 0;
	else
	  	return 1;
	fi
}

# Checking the username GetUserAndDomainDetailsFromCurrentLocation and getting the domain name GetUserAndDomainDetailsFromCurrentLocation from the username 
# This will only work on the cPanel server.
GetUserAndDomainDetailsFromCurrentLocation(){
	if ! check_cpanel 
	then 
		echo "The server does not seems to be cPanel sever" 
		exit 1
	fi
	user=$(pwd| awk -F'/' '{print $3}')
	if grep -q $user /etc/trueuserdomains
	then
		domain=$(grep $user /etc/trueuserdomains |cut -d: -f1)
		echo "$user $domain"
	else # The server is a cPanel server, but the user is nowhere to be found
		echo "user not found"
		exit 0
	fi
}


# init function where the program execution begins
init(){
	case "$1" in
		apache)
			check_cpanel
			read -p "Enter the domain name(Press enter if you are already in the homedirectory): "
			domain=$REPLY
			if [ -z $REPLY ]
			then
				read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
				echo "user :$user"
				echo "domain :$domain"
				if [[ -z $domain || -z $user ]];
				then
					echo "domain or user not found"
					exit 0;
				fi
			fi
			grep $domain $apacheErrorLog|less
			;;
		nginx)
			read -p "Enter the domain name(Press enter if you are already in the homedirectory): "
			domain=$REPLY
			if [ -z $domain ]
			then 
				echo "no domain provided"
				read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
			fi
			grep -i $(echo $domain |tr A-Z a-z) $nginxErrorLog |less
		;;
		add_custom_rule)
			domain=$2;
			sed "s/testdomain.com/$domain/g" custom_rule |sed "s/placeholderIp/$(hostname -i)/g"
			read -p "Please confirm to add the above to the custom_rules(Use y or Y):  "
			confirmation=$REPLY
			if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]
			then
				if [[ -f custom_rule && -w $nginx_custom_file ]]; then

					sed "s/testdomain.com/$domain/g" custom_rule | sed "s/154.0.160.141/$(hostname -i)/g" >> "$nginx_custom_file"

					echo "Custom rules added successfully."

				else

					echo -e "${RED}Error: custom_rule file does not exist or $nginx_custom_file is not writable.${NC}"

				fi
			fi
			;; 
		wpinstall)
			wp_install;
		;;
		--h| --help| -help)
			get_help;
		;;
		*)
			main "$@"
		;;
	esac
}

# The function to upgrade the wordpress version prestnt in the domain
wp_upgrade(){
	wget -p $wp_url;
	read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
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

# Lists out the plugins in the installation (Good for debugging)
wp_plugin(){
	plugind=$(find . -type d -name plugins |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "plugin in $plugind"
	ls -al $plugind
}

# Lists out the themes in the installation 
wp_theme(){
	themed=$(find . -type d -name themes |grep -v "wp-include" |grep -v "wordpress/wp-cont")
	echo "theme in $themed"
	ls -al $themed
}

# Code for installing wordpress without UI
wp_install(){
	wget -p $wp_url;
	read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
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

# Help functionality
get_help(){ 
	cat help.txt |grep -v "###"
}

init "$@"
