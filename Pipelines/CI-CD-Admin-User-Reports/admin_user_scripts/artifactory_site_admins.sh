#!/bin/bash

# Artifactory base URL
BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# API token for authentication
API_TOKEN="$ARTIFACTORY_TOKEN"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")
# Output CSV file
OUTPUT_FILE="artifactory_admin_users_$timestamp.csv"
# Delay duration in seconds
DELAY=2

# Add CSV header
echo "Name,Email,Admin,Groups,LastLoggedIn" > $OUTPUT_FILE

# Get the list of all users
users=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET "$BASE_URL/api/security/users" | jq -r '.[].name')

# Loop through each user
while IFS= read -r user_name; do
  echo "Fetching information for user: $user_name"

  # Encode the username to handle spaces, periods, and special characters
  encoded_user_name=$(echo "$user_name" | sed -e 's/ /%20/g' -e "s/'/%27/g" -e 's/\./%2E/g')

  # Fetch user information
  user_info=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
    -X GET "$BASE_URL/api/security/users/$encoded_user_name")

  # Extract required fields from JSON response
  name=$(echo "$user_info" | jq -r '.name // "N/A"')
  email=$(echo "$user_info" | jq -r '.email // "N/A"')
  admin=$(echo "$user_info" | jq -r '.admin // false')
  groups=$(echo "$user_info" | jq -r '.groups[]? // "N/A"' | tr '\n' ';')
  last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

  # Check if the user is in the Admins group
  if echo "$groups" | grep -q "Admins"; then
    # Append the data to the CSV file
    echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE
  fi

  # Introduce a delay between calls
  sleep $DELAY
done <<< "$users"

echo "User information exported to $OUTPUT_FILE"
