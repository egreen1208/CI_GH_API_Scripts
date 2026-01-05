#!/bin/bash

# Define the API endpoint and authorization token
api_endpoint="https://DOMAIN_NAME/rest/api/2/user/search?username=.&includeInactive=true&startAt=0&maxResults=500"
group_endpoint="https://DOMAIN_NAME/rest/api/2/group?groupname=jira-administrators&expand=users"
authorization_token="$JIRA_TOKEN"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Make the API call to get the members of the jira-administrators group
group_response=$(curl -s -H "Authorization: Bearer $authorization_token" -H "Content-Type: application/json" -X GET "$group_endpoint")

# Check if the request was successful
if [ $? -eq 0 ]; then
  echo "Group members retrieved successfully:"

  # Extract the usernames of the group members
  group_users=$(echo "$group_response" | jq -r '.users.items[].name')

  # Make the API call to get all users
  response=$(curl -s -H "Authorization: Bearer $authorization_token" -H "Content-Type: application/json" -X GET "$api_endpoint")

  # Check if the request was successful
  if [ $? -eq 0 ]; then
    echo "Users retrieved successfully:"

    # Define the output file name
    output_file="jira_admin_users_$timestamp.csv"

    # Add headers to the CSV file
    echo "name,displayName,active,emailAddress" > "$output_file"

    # Filter the JSON response to return only the specified fields for users in the jira-administrators group and append to the CSV file
    echo "$response" | jq -r --argjson group_users "$(echo "$group_users" | jq -R -s -c 'split("\n")[:-1]')" '
      .[] | select(.name as $name | $group_users | index($name)) | [.name, .displayName, .active, .emailAddress] | @csv' >> "$output_file"

    echo "Filtered user information has been exported to $output_file"
  else
    echo "Failed to retrieve users."
    echo "Response: $response"
  fi
else
  echo "Failed to retrieve group members."
  echo "Response: $group_response"
fi
