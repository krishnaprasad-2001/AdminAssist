# Capture command details along with the username who invoked the script/function and the command used
# Append to log file
BASE_DIR=$(dirname "$(realpath "$0")")

# Load required files using absolute paths
source "$BASE_DIR/configuration.conf"

# Simple logging function for the main function 
log(){
	if [ $ENABLE_LOGGING -eq 1 ]
	then
		TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
		USER=$(whoami)
		DIRECTORY=$(pwd)
		COMMAND="$0 $*"  # Captures full command with arguments
		echo "[$TIMESTAMP] User: $USER | Directory: $DIRECTORY | Command: $COMMAND" >> $COMMAND_LOG &> /dev/null
		echo >> $COMMAND_LOG &>/dev/null
	fi

}

# Function to log the details along with the function name called and the details on the user and the time in which the function was called
flog() {
	if [ $ENABLE_LOGGING -eq 1 ]
	then
		# echo >> $COMMAND_LOG
		local caller="${FUNCNAME[1]}"  # Gets the name of the function that called `log`
		local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
		local user="$USER"
		local cwd="$(pwd)"
		echo "[$timestamp] [$user] [Function: $caller] [Dir: $cwd] - $1" >> "$COMMAND_LOG" &>/dev/null
	fi
}
