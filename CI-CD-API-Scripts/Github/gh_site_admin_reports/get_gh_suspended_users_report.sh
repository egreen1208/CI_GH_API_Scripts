#!/bin/bash

# Run this script to download the suspended users report into your current directory.
# Be sure to insert your GitHub username and access token. For example: 'smokey-bear:"xxxxxxxxxxxxxxxxxxxxxx"'
# Make sure your token has the "Site-Admin" permission scope in order to run this script.

# Replace these values with your actual GitHub username and access token.
username="Your_Username"
access_token="Your-Token"

# Ensure the URL scheme is correct (http or https)
url="https://code.fs.usda.gov/stafftools/reports/suspended_users.csv"

# Initialize variables
max_retries=10
retry_count=0
retry_delay=10

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Function to download the report
download_report() {
  response=$(curl -s -w "\nHTTP_STATUS_CODE:%{http_code}\n" --user "$username:$access_token" "$url")
  http_status=$(echo "$response" | grep "HTTP_STATUS_CODE" | awk -F: '{print $2}' | tr -d '[:space:]')
  response_body=$(echo "$response" | sed -e 's/HTTP_STATUS_CODE\:.*//g')
}

# Retry loop
while [ $retry_count -lt $max_retries ]; do
  download_report

  # Print the HTTP status code for debugging
  echo "HTTP Status Code: $http_status"

  if [ "$http_status" -eq 200 ]; then
    echo "Report downloaded successfully."

    # Save the response body to a timestamped CSV file
    output_file="gh_suspended_users_$timestamp.csv"
    echo "$response_body" > "$output_file"

    echo "Filtered user information has been exported to $output_file"
    exit 0
  else
    echo "Failed to download the report. HTTP Status Code: $http_status"
    echo "Response: $response_body"
    echo "Retrying in $retry_delay seconds..."
    sleep $retry_delay
    retry_count=$((retry_count + 1))
  fi
done

echo "Failed to download the report after $max_retries attempts."
exit 1