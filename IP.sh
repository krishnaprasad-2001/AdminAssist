#!/bin/bash
BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/ansi_colors.sh"

is_private_ip() {
	ip="$2"
	# To prevent blank IP addresses to be provided intor the validity function.
	if [[ -z $ip ]]
	then
		echo -e "$RED IP address blank$NC"
		exit 1;
	fi
	checkIpValidity $ip 
	# Check for private IP ranges
	if [[ "$ip" =~ ^10\. || \
		"$ip" =~ ^192\.168\. || \
		"$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
			echo "IP is private"
		else
			echo "IP is public"
	fi
}

# checking if the IP is a valid IP ( As in the fact that every IP have 4 octects each)
function checkIpValidity(){
    local ip="$1"
    # Pattern on how an IP should look like
    local octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
    local pattern="^$octet\\.$octet\\.$octet\\.$octet$"

    if [[ "$ip" =~ $pattern ]]; then
        echo "Valid IPv4 address: $ip"
    else
        echo -e "$RED Invalid IPv4 address: $BLUE $ip $NC"
	# Just exit the stupid script if the IP is not valid (why bother to check if its private or public if it doesn't exist)
	exit 1;
    fi
}
