#!/bin/bash

# Configuration
org_name="ORG_NAME" # Replace with your organization's name
team_slug="TEAM_NAME"   # Replace with the team's slug (name in URL)
output_file="team_members.csv"

# Function to fetch team members
fetch_members() {
  gh api "orgs/$org_name/teams/$team_slug/members" --paginate \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $gh_token" | jq -r '.[] | [.login, .name, .email] | @csv'
}

# Clear the output file and add a header row
echo "login,name,email" > "$output_file"

# Fetch members and append to the CSV
fetch_members >> "$output_file"

echo "Team members exported to $output_file"


# gh api orgs/forest-service/teams/NRM/members --paginate | jq -r '.[] | [.login] | @csv' 
