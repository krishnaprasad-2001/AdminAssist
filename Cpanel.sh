# Checking the username GetUserAndDomainDetailsFromCurrentLocation and getting the domain name GetUserAndDomainDetailsFromCurrentLocation from the username 
# This will only work on the cPanel server.
GetUserAndDomainDetailsFromCurrentLocation(){
	flog
	if ! check_cpanel 
	then 
		echo "NoCpanel NoCpanel"
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

check_cpanel(){
	flog
	if [ -e /etc/trueuserdomains ]
	then
		return 0;
	else
	  	return 1;
	fi
}


