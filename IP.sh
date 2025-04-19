#!/bin/bash

is_private_ip() {
	ip="$2"
	checkIpValidity($2)
	# Check for private IP ranges
	if [[ "$ip" =~ ^10\. || \
		"$ip" =~ ^192\.168\. || \
		"$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
			echo "IP is private"
		else
			echo "IP is public"
	fi
}

checkIpValidity(){
    local ip="$1"
    local octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
    local pattern="^$octet\\.$octet\\.$octet\\.$octet$"

    if [[ "$ip" =~ $pattern ]]; then
        echo "Valid IPv4 address: $ip"
    else
        echo "Invalid IPv4 address: $ip"
    fi
}
