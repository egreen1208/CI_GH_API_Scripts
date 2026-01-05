#!/bin/bash

# Define the API endpoint and authorization token
api_endpoint="https://DOMAIN_NAME/rest/api/2/user/search?username=.&includeInactive=true&startAt=0&maxResults=500"
authorization_token="Your_Token"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Make the API call using curl
response=$(curl -s -H "Authorization: Bearer $authorization_token" -H "Content-Type: application/json" -X GET "$api_endpoint")

# Check if the request was successful
if [ $? -eq 0 ]; then
  echo "Users retrieved successfully:"

  # Define the output file name
  output_file="jira_users_$timestamp.csv"

  # Add headers to the CSV file
  echo "name,displayName,active,emailAddress" > "$output_file"

  # Filter the JSON response to return only the specified fields and append to the CSV file
  echo "$response" | jq -r '.[] | [.name, .displayName, .active, .emailAddress] | @csv' >> "$output_file"

  echo "Filtered user information has been exported to $output_file"
else
  echo "Failed to retrieve users."
  echo "Response: $response"
fi
