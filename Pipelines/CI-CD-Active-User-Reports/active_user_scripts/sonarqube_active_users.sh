#!/bin/bash

sonarqube_url="https://sca.fedgovcloud.us"
api_token="$SQ_TOKEN"
timestamp=$(date +"%Y-%m-%d_%H%M")
FILENAME="SonarQube_users_$timestamp.csv"

endpoint="/api/users/search"
page=1
page_size=50

echo "login,name,email,last_connection_date" > $FILENAME

while true; do
    response=$(curl -s -u "$api_token:" -X GET "$sonarqube_url$endpoint?p=$page&ps=$page_size")

    if [ $? -eq 0 ]; then
        echo "$response" | jq -r '.users[] | [.login, .name, .email, .lastConnectionDate] | @csv' >> $FILENAME
        total=$(echo "$response" | jq -r '.paging.total')
        total_pages=$(( (total + page_size - 1) / page_size ))

        if [ $page -ge $total_pages ]; then
            break
        fi

        page=$((page + 1))
    else
        echo "Failed to retrieve users."
        echo "Response: $response"
        break
    fi
done