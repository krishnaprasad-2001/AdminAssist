#!/bin/bash
BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/ansi_colors.sh"
source "$BASE_DIR/configuration.conf"
source "$BASE_DIR/fun.sh"
# This module will be used to implement the functions that will be used to check the script health and fix if any issues found. ( Useless :) lets just face it this thing itself is beyond saving. )

OLD_IFS="$IFS"
installed=""
not_installed=""

# Checks if all the dependency that the script requires is installed already. The dependencies are in the file dependency.txt
function check_dependency(){
	for dependency in $(cat $BASE_DIR/dependency.txt)
	do 
		# This checks if the command is installed.
		if command -V $dependency &> /dev/null
		then
			# installed dependencies are stored for any later use 
			installed+=$dependency:
		else
			# Non existent dependencies are stored to let know what more needs to be installed
			not_installed+=$dependency:
		fi
	done
	IFS=":"
	if [ "$not_installed" == "" ]
	then
		# All the script dependencies are installed 
		echo -e "$YELLOW[ Dependency check ✓ ] $BLUE -> All the dependency is installed is installed. $NC"
	else
		# All requirementss for the script functionality not installed
		echo -e "$BOLD$RED[ Dependency check ✗ ] -> The below dependencies are not installed. Please install them with the package manager of your choice. $NC"
		for dependency in $not_installed
		do
			echo "$dependency"
		done
		IFS=$OLD_IFS
	fi
}

# function to check if all the script logs are accessible and writeable
function verify_log_accessibility()
{
	for scriptLog in $COMMAND_LOG $ERROR_LOG
	do 
		if [ ! -f $scriptLog ] 
		then
			non_existant_log+=$scriptLog:
			continue;
		else
			if [ ! -w $scriptLog ] 
			then
				non_writeable_log+=$scriptLog:
			fi

		fi
	done
	if [[ $non_writeable_log != "" || $non_existant_log != "" ]]
	then
		echo -e "$BOLD$RED[  Script log check ✗ ] -> The script Logging is faulty$NC"
	else
		echo -e "$YELLOW[ Logging check ✓ ] $BLUE -> All the script logs seems to accessible. $NC"
	fi
	if [[ non_existant_log != "" ]]
	then
		IFS=:
		for script_log in $non_existant_log
		do 
			echo -e "$RED Log \"$script_log\" does not exist$NC"
		done
	fi
	if [[ non_writeable_log != "" ]]
	then
		IFS=:
		for script_log in $non_writeable_log
		do 
			echo -e "$CYAN Log \"$scriptLog\" is non writable ( You sure you are the right user? )$NC"
		done
	fi
	IFS=$OLD_IFS
}

function checkModules() {
	missing_module_files=""
	IFS="="
	while read module file
	do
		if [[ ! -e $BASE_DIR/$file ]]
		then
			missing_module_files+=$module+$file:
		fi
	done < $BASE_DIR/modules
	if [[ $missing_module_files != "" ]]
	then
			echo -e "$BOLD$RED[ Script Modules check ✗ ] -> Below Modules seems to be missing$NC"
			#echo -e "$RED""The module $module file seems to be missing. Please check the$YELLOW $file$RED in the installation directory$NC"
	else
		echo -e "$YELLOW[ Module check ✓ ] $BLUE -> All the Script module files present. $NC"
	fi
			
}

function check_health(){
	check_dependency
	verify_log_accessibility
	checkModules
}

