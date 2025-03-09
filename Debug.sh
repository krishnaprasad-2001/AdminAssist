BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/configuration.conf"

execute() {
    if [ "$SCRIPT_DEBUG" -eq 1 ]; then
        "$@"  # Execute command normally
    else
        "$@" &> "$ERROR_LOG"  # Execute command with error redirection
    fi
}
