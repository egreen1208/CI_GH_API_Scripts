#!/bin/bash

# Replace these values with your SonarQube instance URL, username, and API token.
sonarqube_url="https://sca.fedgovcloud.us"
api_token="Your_token"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Define the endpoint to get all users.
endpoint="/api/users/search"

# Initialize variables for pagination
page=1
page_size=50

# Write the CSV header
echo "login,name,email,last_connection_date" > SonarQube_users_$timestamp.csv

# Loop to handle pagination
while true; do
  # Make the API call using curl with the -u option for authentication.
  response=$(curl -s -u "$api_token:" -X GET "$sonarqube_url$endpoint?p=$page&ps=$page_size")

  # Check if the request was successful.
  if [ $? -eq 0 ]; then
    # Extract user details and append to the CSV file
    echo "$response" | jq -r '.users[] | [.login, .name, .email, .lastConnectionDate] | @csv' >> SonarQube_users_$timestamp.csv

    # Get the total number of users
    total=$(echo "$response" | jq -r '.paging.total')

    # Calculate the number of pages
    total_pages=$(( (total + page_size - 1) / page_size ))

    # Check if we have retrieved all pages
    if [ $page -ge $total_pages ]; then
      break
    fi

    # Increment the page number
    page=$((page + 1))
  else
    echo "Failed to retrieve users."
    echo "Response: $response"
    break
  fi
done

echo "Users have been exported to SonarQube_users_$timestamp.csv"