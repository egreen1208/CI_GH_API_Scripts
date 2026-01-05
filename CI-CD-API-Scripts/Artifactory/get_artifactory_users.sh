#!/bin/bash

# Define the API endpoint and authorization token
api_endpoint="https://artifactory.fdc.fs.usda.gov/artifactory/api/admin/management/users"
authorization_token="Your_Token"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Make the API call using curl
response=$(curl -s -H "Authorization: Bearer $authorization_token" -X GET "$api_endpoint")

# Check if the request was successful
if [ $? -eq 0 ]; then
  echo "Users retrieved successfully:"

  # Convert the JSON response to CSV format using jq
  echo "$response" | jq -r '
    def safe_join(arr):
      if (arr | type) == "array" then arr | join(",") else arr end;
    def null_to_empty:
      if . == null then "" else . end;
    ["name", "email", "realm", "groups", "admin", "status", "lastLoggedIn"] as $keys |
    $keys,
    (map({($keys[]): .[$keys]}) | .[]) | [.name, .email, .realm, (safe_join(.groups)), (.admin | tostring), .status, .lastLoggedIn] | map(null_to_empty) | @csv
  ' > artifactory_users_$timestamp.csv

  echo "Users have been exported to artifactory_users_$timestamp.csv"
else
  echo "Failed to retrieve users."
  echo "Response: $response"
fi
