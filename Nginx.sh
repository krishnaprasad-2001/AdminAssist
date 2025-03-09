BASE_DIR=$(dirname "$(realpath "$0")")
checkNginxErrorLog(){
	read -p "Enter the domain name(Press enter if you are already in the homedirectory): "
	domain=$REPLY
	if [ -z $domain ]
	then 
		echo "no domain provided"
		read user domain < <(GetUserAndDomainDetailsFromCurrentLocation);
	fi
	if [ $user = "user" ]
	then
		echo -e "no user found\nScript exiting"
		exit 1;
	fi
	grep -i $(echo $domain |tr A-Z a-z) $nginxErrorLog |less
}
add_custom_rule()
{
	domain=$2;
	if [ -z "$domain" ]
	then
		echo "no domain found"
		exit 1;
	fi
	sed "s/testdomain.com/$domain/g" $nginx_custom_file |sed "s/placeholderIp/$(hostname -i)/g"
	echo
	read -p "Please confirm to add the above to the custom_rules(Use y or Y):  "
	confirmation=$REPLY
	if [[ "$confirmation" == "y" || "$confirmation" == "Y" ]]
	then
		if [[ -f custom_rule && -w $nginx_custom_file ]]; then
			eval "cp $nginx_custom_file ${nginx_custom_file}_script_backed"
			sed "s/testdomain.com/$domain/g" custom_rule | sed "s/154.0.160.141/$(hostname -i)/g" >> "$nginx_custom_file"
			echo "Custom rules added successfully."
			if nginx -t &>/dev/null
			then
				echo "Nginx test succesfull"
				read -p "Proceed with restart: "
				REPLY=$(echo "$REPLY" |xargs);
				if [[ $REPLY = "y" || $REPLY = "Y" ]]
				then
					service nginx restart;
					service nginx status |head -n 5
				else
					echo "service not restarted and needs manual restart";
					echo "use \" service nginx restart \""
				fi
			fi

		else
			echo -e "${RED}Error: custom_rule file does not exist or $nginx_custom_file is not writable.${NC}"

		fi
	fi
}
