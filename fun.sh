#!/bin/bash
BASE_DIR=$(dirname "$(realpath "$0")")
source "$BASE_DIR/configuration.conf"

print_doggy(){
	if [ $DOG_LOVER -ne 1 ]
	then 
		return
	fi
	echo "Admin Assist, A man's second best friend"
	echo "(Because the first best friend is always a dog! 🐕)"
	echo '
	  /^ ^\
	 / 0 0 \
	 V\ Y /V
	  / - \
	 /    |
	V__) ||'
}
fetch_motivation() {
    response=$(curl -s "https://zenquotes.io/api/random")

    # Extracting the quote and author using grep, awk, and sed
    quote=$(echo "$response" | grep -o '"q":"[^"]*' | sed 's/"q":"//')
    author=$(echo "$response" | grep -o '"a":"[^"]*' | sed 's/"a":"//')
    echo "\"$quote\""
}
fetch_motivation_list() {
    echo -e "\n🌟 Stay Strong! Here's a Motivation Boost:\n"

    # Predefined Motivational Quotes
    quotes=(
        "Success is not final, failure is not fatal: It is the courage to continue that counts. - Winston Churchill"
        "Do not watch the clock. Do what it does. Keep going. - Sam Levenson"
        "Hardships often prepare ordinary people for an extraordinary destiny. - C.S. Lewis"
        "Tough times never last, but tough people do. - Robert H. Schuller"
        "Believe you can, and you're halfway there. - Theodore Roosevelt"
        "The struggle you’re in today is developing the strength you need for tomorrow. - Robert Tew"
        "It always seems impossible until it’s done. - Nelson Mandela"
        "Failure is the opportunity to begin again, more intelligently. - Henry Ford"
        "When you feel like quitting, think about why you started. - Unknown"
    )

    # Select a random quote
    random_quote="${quotes[$RANDOM % ${#quotes[@]}]}"

    # Print it in a fun ASCII-styled box
    echo "╔════════════════════════════════════╗"
    echo "║  $random_quote"
    echo "╚════════════════════════════════════╝"
    echo
}

print_sad_dog() {
	if [ $DOG_LOVER -ne 1 ]
	then 
		return 
	fi
	    echo "Even Admin Assist's tail stopped wagging... Goodbye! 😢"
	    echo '
	      / \__
	     (    @\____
	      /         O
	     /   (_____/
	    /_____/   U
	    '
}
