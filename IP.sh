#!/bin/bash

is_private_ip() {
	ip="$2"
	# Check for private IP ranges
	if [[ "$ip" =~ ^10\. || \
		"$ip" =~ ^192\.168\. || \
		"$ip" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]]; then
			echo "IP is private"
		else
			echo "IP is public"
	fi
}
