#!/bin/bash
# flog command used in each function to log details when each function is invoked to the command.log file 
# sourcing the file containing the Tools for database coloring and other configuration
# Resolve script directory even if BK.sh is executed from another location
BASE_DIR=$(dirname "$(realpath "$0")")
help_file="$BASE_DIR/help.txt"

# Load required files using absolute paths
source "$BASE_DIR/Debug.sh"
source "$BASE_DIR/log.sh"
source "$BASE_DIR/IP.sh"
source "$BASE_DIR/fun.sh"
source "$BASE_DIR/configuration.conf"
source "$BASE_DIR/ansi_colors.sh"
source "$BASE_DIR/Wordpress.sh"
source "$BASE_DIR/Nginx.sh"
source "$BASE_DIR/log.sh"
source "$BASE_DIR/ScriptHealth.sh"
source "$BASE_DIR/Cpanel.sh"
custom_rule="$BASE_DIR/custom_rule"

# Wordpress latest version to use for upgrade
wp_url="https://wordpress.org/latest.zip"

# main function 
main() {
	flog
	installation=$(find_installation);
	case "$installation" in
		wp)
			wordpress "$@"
			;;
		*)
			echo "seems like you are lost"
			echo 
			print_doggy
			get_help
			;;
	esac
}

# check if installation is wordpress
check_wp(){
	flog
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
	flog
	if [ -e index.php ]
	then
		main "$@"
	else
		echo "index file not found"
	fi
}


# check if the server is a cPanel server or not ( if not, the implementaion could differ)

# init function where the program execution begins
init(){
	log
	flog
	case "$1" in
		apache)
			check_cpanel
			read -p "Enter the domain name(Press enter if you are already in the homedirectory): "
			domain=$REPLY
			if [ -z $REPLY ]
			then
				read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
				if [[ $user == "NoCpanel" ]]
				then
					echo -e "$RED""User not found$NC"
					exit 1;
				fi
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
			checkNginxErrorLog
		;;
		add_custom_rule)
			add_custom_rule "$@"
			;; 
	       ipcheck)
			is_private_ip "$@"
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
		checkhealth|check_health)
			check_health;
		;;
		chat|aichat)
			chat;
		;;
		dockertest)
			dockertest;
		;;
		dockerforktest)
			dockerforktest;
		;;
		*)
			main "$@"
		;;
	esac
}

# Help functionality
get_help(){ 
	flog
	cat $help_file |grep -v "###"
}

find_installation(){
	flog
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
	flog
	print_sad_dog
	# Removing the shortcut from the bashrc file to prevent error as autocompletion file would be removed
	execute sed -i '/\/opt\/AdminAssist\/autoCompletion.sh/d' ~/.bashrc
	execute rm -r /opt/AdminAssist /usr/bin/BK 
	if [ $? -ne 0 ]
	then
		echo "installation removed"  
	fi
}

function chat(){
	 $BASE_DIR/chat
}

function dockertest() {
	if command -v docker &>/dev/null
	then
		read -p 'enter the name of the container: '
		container_name=$REPLY

		if [[ "$container_name" =~ ^[a-z0-9]+([-.][a-z0-9]+)*$ ]]
		then
			:
		else
			read -p "Invalid Docker name. Proceed with the name admin-assist-docker ? ( Enter y or Y to proceed )"
			    response=$REPLY
			if [[ $response == 'y' || $response == 'Y' ]]
			then
				container_name='admin-assist-docker'
			else
				return 2 &>/dev/null || exit 2
			fi
		fi
		read -p 'Do you want the tool to be pre-installed?'
		response=$REPLY
		echo "Proceeding with creating a container with the name $container_name"
		if [[ $response == 'y' || $response == 'Y' ]]
		then
			sudo docker build --build-arg INSTALL_SCRIPT=true -t $container_name .	
		else
			sudo docker build -t $container_name .
		fi
		sudo docker run -it $container_name bash
	else
		echo "Docker does not seems to be installed"
		exit
	fi
}

function dockerforktest() {
	if command -v docker &>/dev/null
	then
		read -p 'enter the name of the container: '
		container_name=$REPLY
		if [[ "$container_name" =~ ^[a-z0-9]+([-.][a-z0-9]+)*$ ]]
		then
		    echo "Proceeding with creating a container with the name $container_name"
		else
			read -p "Invalid Docker name. Proceed with the name admin-assist-fork ? ( Enter y or Y to proceed )"
			    response=$REPLY
			if [[ $response == 'y' || $response == 'Y' ]]
			then
			echo 'Generating container with tool installed'
				container_name='admin-assist-fork'
			else
				return 2 &>/dev/null || exit 2
			fi
		fi
		read -p 'Do you want the tool to be pre-installed?'
		response=$REPLY
		echo "Proceeding with creating a container with the name $container_name"
		if [[ $response == 'y' || $response == 'Y' ]]
		then
			echo 'Generating container with tool installed'
			sudo docker build --build-arg INSTALL_SCRIPT=true -t $container_name  -f Dockerfile2 .
		else
			sudo docker build -t $container_name -f Dockerfile2 .
		fi
		sudo docker run -it $container_name bash
	else
		echo "Docker does not seems to be installed"
		exit
	fi
}
init "$@"
