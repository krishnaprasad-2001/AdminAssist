service=$1

if ! command -v systemctl &>/dev/null
then
	echo "Systmectl not configured"
fi

if systemctl list-unit-files --type=service | grep -q "$service"; then
	matches=$(systemctl list-unit-files --type=service | grep "$service" | awk '{print $1}' | wc -l)

	if [ "$matches" -gt 1 ]; then
		serviceList=$(systemctl list-unit-files --type=service | grep "$service")
		SELECTED=$(echo "$serviceList" | fzf --prompt="Pick a service: ")
		# SELECTED=$(echo "$serviceList" | gum choose)
		service=$(echo "$SELECTED" | awk '{print $1}')
	else
		service=$(systemctl list-unit-files --type=service | grep "$service" | awk '{print $1}')
	fi
else
	echo "❌ Service not found"
	exit 1
fi

echo "✅ Selected service: $service"
journalctl -xeu $service |tail -n 50 >log.txt
systemctl status $service >> log.txt

if grep -q 'No entries' log.txt
then
	echo "I cannot seem to find any issues. Please ensure to restart services to generate the log files"
	exit 1
else
	./chat2 log.txt
fi
