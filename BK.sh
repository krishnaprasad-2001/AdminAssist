#!/bin/bash

# sourcing the file containing the Tools for database coloring and other configuration
# Resolve script directory even if BK.sh is executed from another location
BASE_DIR=$(dirname "$(realpath "$0")")

# Load required files using absolute paths
source "$BASE_DIR/configuration.conf"
source "$BASE_DIR/ansi_colors.sh"
source "$BASE_DIR/Wordpress.sh"
custom_rule="$BASE_DIR/custom_rule"

# Wordpress latest version to use for upgrade
wp_url="https://wordpress.org/latest.zip"

# main function 
main() {
	installation=$(find_installation);
	case "$installation" in
		wp)
			wordpress "$@"
			;;
		*)
			echo "❌ Unknown module: $1";
			get_help
			;;
	esac
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
			sed "s/testdomain.com/$domain/g" $custom_rule |sed "s/placeholderIp/$(hostname -i)/g"
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
		uninstall)
			uninstall;
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

# Help functionality
get_help(){ 
	cat help.txt |grep -v "###"
}
find_installation(){
	if [ -f index.php ]
	then
		if grep -q "wp-blog-header.php" index.php ]] # checking for the wp-blog-header reference in the index file(to confirm the installation kind)
		then
			echo "wp"
		else 
			echo "joomla"
		fi
	fi
}

uninstall(){
	rm -r /opt/AdminAssist /usr/bin/BK || echo "Corrupt installation removed" 
}

init "$@"
