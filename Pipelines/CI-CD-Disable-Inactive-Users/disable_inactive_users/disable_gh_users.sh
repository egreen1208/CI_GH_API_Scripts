#!/bin/bash

# Define variables
access_token="$GITHUB_TOKEN"
url="https://DOMAIN_NAME/stafftools/reports/dormant_users.csv"
timestamp=$(date +"%Y-%m-%d_%H%M")
dormant_users="dormant_users_$timestamp.csv"
suspended_users="gh_disabled_users_$timestamp.csv"
max_retries=5
retry_delay=10

# Dynamically calculate the date 60 days ago
sixty_days_ago=$(date -d "-60 days" +"%Y-%m-%d")

# Function to download the CSV file with retry mechanism
download_csv() {
  local retries=0
  while [ $retries -lt $max_retries ]; do
    curl -H "Authorization: Bearer $access_token" "$url" -o "$dormant_users"
    if [ $? -eq 0 ]; then
      echo "CSV file downloaded successfully."
      return 0
    else
      echo "Failed to download CSV file. Retrying in $retry_delay seconds..."
      retries=$((retries + 1))
      sleep $retry_delay
    fi
  done
  echo "Failed to download CSV file after $max_retries attempts."
  return 1
}

# Step 1: Download the CSV file
if ! download_csv; then
  echo "Exiting script due to download failure."
  exit 1
fi

# Step 2: Parse the CSV file and filter for users inactive for 60+ days
awk -F, -v cutoff="$sixty_days_ago" 'BEGIN {OFS=","} NR==1 || $12 < cutoff' "$dormant_users" > "$suspended_users"

# Print success message for filtering
echo "Filtered list of dormant users (inactive since $sixty_days_ago) saved to $suspended_users"

# Step 3: Suspend accounts listed in the suspended_users file
while IFS=',' read -r created_at id login email role suspended last_logged_ip repos ssh_keys org_memberships dormant last_active raw_login two_fa_enabled ssh_keys_last_access pats pats_last_access; do
    # Skip the header row and ensure login is not empty
    if [ "$login" != "login" ] && [ -n "$login" ]; then
        echo "Suspending user: $login"

        # API request to suspend the user and capture response
        response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $access_token" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "https://code.fs.usda.gov/api/v3/users/$login/suspended" \
            -d '{"reason":"Suspended due to inactivity"}')

        # Log the response for debugging
        if [ "$response" -eq 204 ]; then
            echo "Successfully suspended user: $login"
        elif [ "$response" -eq 404 ]; then
            echo "User not found: $login (HTTP status: $response)"
        elif [ "$response" -eq 403 ]; then
            echo "Permission denied for suspending user: $login (HTTP status: $response)"
        else
            echo "Failed to suspend user: $login (HTTP status: $response)"
        fi
    fi
done < "$suspended_users"

echo "Suspension process completed for users in $suspended_users"
