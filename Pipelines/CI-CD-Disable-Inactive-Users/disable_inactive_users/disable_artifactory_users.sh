# #!/bin/bash

# # Artifactory base URL
# BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# # API token for authentication
# API_TOKEN="cmVmdGtuOjAxOjE3NzAyMTA1MDY6Q2RmUkh0eFJMZTBPS2FZeGRSMFJmU2hBckJh"

# # Generate a timestamp for the output file name
# timestamp=$(date +"%Y-%m-%d_%H%M")
# # Output CSV file
# OUTPUT_FILE="artifactory_inactive_users_$timestamp.csv"
# # Delay duration in seconds
# DELAY=2

# # Calculate the cutoff date (60 days ago)
# cutoff_date=$(date -d "-60 days" +"%Y-%m-%dT%H:%M:%S")

# # List of service accounts to skip (normalized to lowercase)
# service_accounts=(
#   "services"
#   "jenkins_artifactory_services"
#   "service-account-cio-write"
#   "jenkins services"
#   "sqapiuser"
#   "anonymous"
#   "test_jenkins_svc_user"
#   "apiuser"
#   "fit_serviceaccount"
#   "jenkins"
#   "service-account-cio-read"
#   "admin"
#   "s_apiuser"
#   "nrm_serviceaccount"
#   "puppet_download"
# )

# # Add CSV header
# echo "Name,Email,Admin,Groups,LastLoggedIn" > $OUTPUT_FILE

# # Get the list of all users
# users=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET "$BASE_URL/api/security/users" | jq -r '.[].name')

# # Loop through each user
# while IFS= read -r user_name; do
#   # Normalize user_name (trim whitespace and convert to lowercase)
#   normalized_user_name=$(echo "$user_name" | tr '[:upper:]' '[:lower:]' | xargs)

#   # Check if the normalized user_name is in the list of service accounts
#   for service_account in "${service_accounts[@]}"; do
#     if [[ "$normalized_user_name" == "$service_account" ]]; then
#       echo "Skipping service account: $user_name"
#       continue 2
#     fi
#   done

#   echo "Fetching information for user: $user_name"

#   # Encode the username to handle spaces, periods, and special characters
#   encoded_user_name=$(echo "$user_name" | sed -e 's/ /%20/g' -e "s/'/%27/g" -e 's/\./%2E/g')

#   # Fetch user information
#   user_info=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
#     -X GET "$BASE_URL/api/security/users/$encoded_user_name")

#   # Extract required fields from JSON response
#   name=$(echo "$user_info" | jq -r '.name // "N/A"')
#   email=$(echo "$user_info" | jq -r '.email // "N/A"')
#   admin=$(echo "$user_info" | jq -r '.admin // false')
#   groups=$(echo "$user_info" | jq -r '.groups[]? // "N/A"' | tr '\n' ';')
#   last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

#   # Check if lastLoggedIn is earlier than the cutoff date (inactive for more than 60 days)
#   if [ "$last_logged_in" != "N/A" ] && [ "$last_logged_in" \< "$cutoff_date" ]; then
#     echo "Adding inactive user: $name (last logged in: $last_logged_in)"
#     # Append the data to the CSV file
#     echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE
#   else
#     echo "Skipping active user: $name (last logged in: $last_logged_in)"
#   fi

#   # Introduce a delay between calls
#   sleep $DELAY
# done <<< "$users"

# echo "Inactive user information exported to $OUTPUT_FILE"


# #!/bin/bash

# # Artifactory base URL
# BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# # API token for authentication
# API_TOKEN="cmVmdGtuOjAxOjE3NzAyMTA1MDY6Q2RmUkh0eFJMZTBPS2FZeGRSMFJmU2hBckJh"

# # Generate a timestamp for the output file name
# timestamp=$(date +"%Y-%m-%d_%H%M")
# # Output CSV file
# OUTPUT_FILE="artifactory_inactive_users_$timestamp.csv"
# # Delay duration in seconds
# DELAY=2

# # Calculate the cutoff date (60 days ago)
# cutoff_date=$(date -d "-60 days" +"%Y-%m-%dT%H:%M:%S")

# # List of service accounts to skip (normalized to lowercase)
# service_accounts=(
#   "services"
#   "jenkins_artifactory_services"
#   "service-account-cio-write"
#   "jenkins services"
#   "sqapiuser"
#   "anonymous"
#   "test_jenkins_svc_user"
#   "apiuser"
#   "fit_serviceaccount"
#   "jenkins"
#   "service-account-cio-read"
#   "admin"
#   "s_apiuser"
#   "nrm_serviceaccount"
#   "puppet_download"
# )

# # Add CSV header
# echo "Name,Email,Admin,Groups,LastLoggedIn" > $OUTPUT_FILE

# # Get the list of all users
# users=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET "$BASE_URL/api/security/users" | jq -r '.[].name')

# # Loop through each user
# while IFS= read -r user_name; do
#   # Normalize user_name (trim whitespace and convert to lowercase)
#   normalized_user_name=$(echo "$user_name" | tr '[:upper:]' '[:lower:]' | xargs)

#   # Check if the normalized user_name is in the list of service accounts
#   for service_account in "${service_accounts[@]}"; do
#     if [[ "$normalized_user_name" == "$service_account" ]]; then
#       echo "Skipping service account: $user_name"
#       continue 2
#     fi
#   done

#   echo "Fetching information for user: $user_name"

#   # Encode the username to handle spaces, periods, and special characters
#   encoded_user_name=$(echo "$user_name" | sed -e 's/ /%20/g' -e "s/'/%27/g" -e 's/\./%2E/g')

#   # Fetch user information
#   user_info=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
#     -X GET "$BASE_URL/api/security/users/$encoded_user_name")

#   # Extract required fields from JSON response
#   name=$(echo "$user_info" | jq -r '.name // "N/A"')
#   email=$(echo "$user_info" | jq -r '.email // "N/A"')
#   admin=$(echo "$user_info" | jq -r '.admin // false')
#   groups=$(echo "$user_info" | jq -r '.groups[]? // "N/A"' | tr '\n' ';')
#   last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

#   # Check if lastLoggedIn is earlier than the cutoff date (inactive for more than 60 days)
#   if [ "$last_logged_in" != "N/A" ] && [ "$last_logged_in" \< "$cutoff_date" ]; then
#     echo "Adding inactive user: $name (last logged in: $last_logged_in)"
#     # Append the data to the CSV file
#     echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE

    # # Disable UI access and remove all groups for the user
    # echo "Disabling UI access and removing groups for user: $name"
    # curl -s -H "Authorization: Bearer $API_TOKEN" \
    #   -H "Content-Type: application/json" \
    #   -X POST "$BASE_URL/api/security/users/$encoded_user_name" \
    #   -d '{"disableUIAccess": true, "groups": []}'
#   else
#     echo "Skipping active user: $name (last logged in: $last_logged_in)"
#   fi

#   # Introduce a delay between calls
#   sleep $DELAY
# done <<< "$users"

# echo "Inactive user information exported to $OUTPUT_FILE"



# #!/bin/bash

# # Artifactory base URL
# BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# # API token for authentication
# API_TOKEN="cmVmdGtuOjAxOjE3NzAyMTA1MDY6Q2RmUkh0eFJMZTBPS2FZeGRSMFJmU2hBckJh"

# # Generate a timestamp for the output file name
# timestamp=$(date +"%Y-%m-%d_%H%M")
# # Output CSV file
# OUTPUT_FILE="artifactory_inactive_users_$timestamp.csv"
# # Delay duration in seconds
# DELAY=2

# # Calculate the cutoff date (60 days ago)
# cutoff_date=$(date -d "-60 days" +"%Y-%m-%dT%H:%M:%S")

# # List of service accounts to skip (normalized to lowercase)
# service_accounts=(
#   "services"
#   "jenkins_artifactory_services"
#   "service-account-cio-write"
#   "jenkins services"
#   "sqapiuser"
#   "anonymous"
#   "test_jenkins_svc_user"
#   "apiuser"
#   "fit_serviceaccount"
#   "jenkins"
#   "service-account-cio-read"
#   "admin"
#   "s_apiuser"
#   "nrm_serviceaccount"
#   "puppet_download"
# )

# # Add CSV header
# echo "Name,Email,Admin,Groups,LastLoggedIn" > $OUTPUT_FILE

# # Get the list of all users
# users=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET "$BASE_URL/api/security/users" | jq -r '.[].name')

# # Loop through each user
# while IFS= read -r user_name; do
#   # Normalize user_name (trim whitespace and convert to lowercase)
#   normalized_user_name=$(echo "$user_name" | tr '[:upper:]' '[:lower:]' | xargs)

#   # Check if the normalized user_name is in the list of service accounts
#   for service_account in "${service_accounts[@]}"; do
#     if [[ "$normalized_user_name" == "$service_account" ]]; then
#       echo "Skipping service account: $user_name"
#       continue 2
#     fi
#   done

#   echo "Fetching information for user: $user_name"

#   # Encode the username to handle spaces, periods, and special characters
#   encoded_user_name=$(echo "$user_name" | sed -e 's/ /%20/g' -e "s/'/%27/g" -e 's/\./%2E/g')

#   # Fetch user information
#   user_info=$(curl -s -H "Authorization: Bearer $API_TOKEN" \
#     -X GET "$BASE_URL/api/security/users/$encoded_user_name")

#   # Extract required fields from JSON response
#   name=$(echo "$user_info" | jq -r '.name // "N/A"')
#   email=$(echo "$user_info" | jq -r '.email // "N/A"')
#   admin=$(echo "$user_info" | jq -r '.admin // false')
#   groups=$(echo "$user_info" | jq -r '.groups[]? // empty' | tr '\n' ';')
#   last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

#   # Skip users with no assigned groups
#   if [ -z "$groups" ]; then
#     echo "Skipping user with no groups: $name"
#     continue
#   fi

#   # Check if lastLoggedIn is earlier than the cutoff date (inactive for more than 60 days)
#   if [ "$last_logged_in" != "N/A" ] && [ "$last_logged_in" \< "$cutoff_date" ]; then
#     echo "Adding inactive user: $name (last logged in: $last_logged_in)"
#     # Append the data to the CSV file
#     echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE
#   else
#     echo "Skipping active user: $name (last logged in: $last_logged_in)"
#   fi

#   # Introduce a delay between calls
#   sleep $DELAY
# done <<< "$users"

# echo "Inactive user information exported to $OUTPUT_FILE"


#!/bin/bash

# Artifactory base URL
BASE_URL="https://artifactory.fdc.fs.usda.gov/artifactory"
# API token for authentication
API_TOKEN="$ARTIFACTORY_TOKEN"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y-%m-%d_%H%M")
# Output CSV file
OUTPUT_FILE="artifactory_disabled_users_$timestamp.csv"
# Delay duration in seconds
DELAY=2

# Calculate the cutoff date (60 days ago)
cutoff_date=$(date -d "-60 days" +"%Y-%m-%dT%H:%M:%S")

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
  # Normalize user_name (trim whitespace and convert to lowercase)
  normalized_user_name=$(echo "$user_name" | tr '[:upper:]' '[:lower:]' | xargs)

  # Check if the normalized user_name is in the list of service accounts
  for service_account in "${service_accounts[@]}"; do
    if [[ "$normalized_user_name" == "$service_account" ]]; then
      echo "Skipping service account: $user_name"
      continue 2
    fi
  done

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
  groups=$(echo "$user_info" | jq -r '.groups[]? // empty' | tr '\n' ';')
  last_logged_in=$(echo "$user_info" | jq -r '.lastLoggedIn // "N/A"')

  # Skip users with no assigned groups
  if [ -z "$groups" ]; then
    echo "Skipping user with no groups: $name"
    continue
  fi

  # Check if lastLoggedIn is earlier than the cutoff date (inactive for more than 60 days)
  if [ "$last_logged_in" != "N/A" ] && [ "$last_logged_in" \< "$cutoff_date" ]; then
    echo "Adding inactive user: $name (last logged in: $last_logged_in)"
    # Append the data to the CSV file
    echo "\"$name\",\"$email\",\"$admin\",\"$groups\",\"$last_logged_in\"" >> $OUTPUT_FILE

    # Disable UI access and remove all groups for the user
    echo "Disabling UI access and removing groups for user: $name"
    curl -s -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      -X POST "$BASE_URL/api/security/users/$encoded_user_name" \
      -d '{"disableUIAccess": true, "groups": []}'
  else
    echo "Skipping active user: $name (last logged in: $last_logged_in)"
  fi

  # Introduce a delay between calls
  sleep $DELAY
done <<< "$users"

echo "Inactive user information exported to $OUTPUT_FILE"