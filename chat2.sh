#!/bin/bash

# Config
API_KEY="YOUR GROK API KEY"
MODEL="meta-llama/llama-4-scout-17b-16e-instruct"
API_URL="https://api.groq.com/openai/v1/chat/completions"

# File input
FILE="$1"

if [[ ! -f "$FILE" ]]; then
  echo "❌ File '$FILE' not found."
  exit 1
fi

# Prepare JSON with jq
JSON=$(jq -n \
  --arg model "$MODEL" \
  --arg content "$(cat "$FILE")" \
  '{
    model: $model,
    messages: [{
      role: "user",
      content: "Analyze the following service logs or status output and give suggestions but act like you are in the server like say it seems that the service also .be serious. In the response, quote the errors so they can check it. also provide the commands to execute to resolve the issue only if it wont break the system:\n\n\($content)"
    }]
  }')

# Send request
curl -s "$API_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d "$JSON" | jq -r '.choices[0].message.content'

