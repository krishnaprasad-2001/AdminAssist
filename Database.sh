BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/log.sh"
source "$BASE_DIR/ansi_colors.sh"
source "$BASE_DIR/Cpanel.sh"

# To check whether the server is a cPanel server as this module is designed for cPanel server.
if ! check_cpanel
then
	echo -e "$RED Not a cpanel server$NC"
	exit 1;
fi

# Prints the existing database details for the given user. All thanks to Deepseek, I was able to figure to print the details regarding the user and the database ( only works for the cPanel servers)
existing_database_details(){
	read -p "Enter the username" username
	for db in $(grep "database:" /var/cpanel/users/$username | cut -d: -f2); do
		# Extract all users (handles multiple users)
		users=$(awk -v db="$db" '
		/database:/ { if ($2 == db) { found=1 } else { found=0 } }
		found && /users:/ {
			while (getline) {
				if ($1 == "-") { print $2 }  # Capture each user
				else { exit }  # Stop if no more users
				}
		}
	' /var/cpanel/users/$username)

	# Count users
	user_count=$(echo "$users" | wc -l)

	# Get disk size in MB
	size_bytes=$(awk -v db="$db" '
	/database:/ { if ($2 == db) { found=1 } else { found=0 } }
	found && /disk_usage:/ { print $2; exit }
	' /var/cpanel/users/test)
	size_mb=$(echo "$size_bytes / (1024 * 1024)" | bc)

	# Print results
	echo "Database: $db"
	echo "Users ($user_count): $(echo "$users" | tr '\n' ' ')"  # List all users in one line
	echo "Size (MB): $size_mb"
	echo "------------------"
done
}
existing_database_details
