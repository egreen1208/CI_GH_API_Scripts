#!/bin/bash

sonarqube_url="https://sca.fedgovcloud.us"
api_token="$SQ_TOKEN"
timestamp=$(date +"%Y%m%d_%H%M%S")
FILENAME="SonarQube_admin_users_$timestamp.csv"

group="sonar-administrators"
endpoint="/api/users/search"
group_endpoint="/api/user_groups/users"
page=1
page_size=50

echo "login,name,email,last_connection_date" > $FILENAME

# Get users in the sonar-administrators group
group_users=$(curl -s -u "$api_token:" -X GET "$sonarqube_url$group_endpoint?name=$group&ps=$page_size" | jq -r '.users[].login')

while true; do
    response=$(curl -s -u "$api_token:" -X GET "$sonarqube_url$endpoint?p=$page&ps=$page_size")

    if [ $? -eq 0 ]; then
        echo "$response" | jq -r --argjson group_users "$(echo "$group_users" | jq -R -s -c 'split("\n")[:-1]')" '
            .users[] | select(.login as $login | $group_users | index($login)) | [.login, .name, .email, .lastConnectionDate] | @csv' >> $FILENAME
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