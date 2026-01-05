#!/bin/bash

# Artifactory base URL
BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# API token for authentication
API_TOKEN="$ARTIFACTORY_TOKEN"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y-%m-%d_%H%M")
# Output CSV file
OUTPUT_FILE="artifactory_users_$timestamp.csv"
# Delay duration in seconds
DELAY=2

# List of service accounts to skip (normalized to lowercase)
service_accounts=(
  "services"
  "jenkins_artifactory_services"
  "service-account-cio-write"
  "jenkins services"
  "sqapiuser"
  "anonymous"
  "test_jenkins_svc_user"
  "apiuser"
  "fit_serviceaccount"
  "jenkins"
  "service-account-cio-read"
  "admin"
  "s_apiuser"
  "nrm_serviceaccount"
  "puppet_download"
)

# Add CSV header
echo "Name,Email,Admin,Groups,LastLoggedIn" > $OUTPUT_FILE

# Get the list of all users
users=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET "$BASE_URL/api/security/users" | jq -r '.[].name')

# Loop through each user
while IFS= read -r user_name; do
  echo "Fetching information for user: $user_name"

  # Normalize user_name (trim whitespace and convert to lowercase)
  normalized_user_name=$(echo "$user_name" | tr '[:upper:]' '[:lower:]' | sed "s/'//g")

  # Check if the normalized user_name is in the list of service accounts
  for service_account in "${service_accounts[@]}"; do
    if [[ "$normalized_user_name" == "$service_account" ]]; then
      echo "Skipping service account: $user_name"
      continue 2
    fi
  done

  # Encode the username to handle spaces, periods, and special characters
  encoded_user_name=$(printf '%s' "$user_name" | jq -s -R -r @uri)

  # Fetch user information
  user_info=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
    -X GET "$BASE_URL/api/security/users/$encoded_user_name")

  # Extract required fields from JSON response
  name=$(echo "$user_info" | jq -r '.name // "N/A"')
  email=$(echo "$user_info" | jq -r '.email // "N/A"')
  admin=$(echo "$user_info" | jq -r '.admin // false')
  groups=$(echo "$user_info" | jq -r '.groups[]? // empty' | tr '\n' ';')
  last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

  # Only append the user to the CSV if they have at least one group
  if [ -n "$groups" ]; then
    echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE
  fi

  # Introduce a delay between calls
  sleep $DELAY
done <<< "$users"

echo "User information exported to $OUTPUT_FILE"