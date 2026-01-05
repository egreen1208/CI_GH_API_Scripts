#!/bin/bash

api_endpoint="https://DOMAIN_NAME/rest/api/2/user/search?username=.&includeInactive=true&startAt=0&maxResults=500"
authorization_token="$JIRA_TOKEN"

timestamp=$(date +"%Y-%m-%d_%H%M")

response=$(curl -s -H "Authorization: Bearer $authorization_token" -H "Content-Type: application/json" -X GET "$api_endpoint")

if [ $? -eq 0 ]; then
    echo "Users retrieved successfully:"
    output_file="jira_users_$timestamp.csv"
    echo "name,displayName,active,emailAddress" > "$output_file"
    echo "$response" | jq -r '.[] | [.name, .displayName, .active, .emailAddress] | @csv' >> "$output_file"
    echo "Filtered user information has been exported to $output_file"
else
    echo "Failed to retrieve users."
    echo "Response: $response"
fi
