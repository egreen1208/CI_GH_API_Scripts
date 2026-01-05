#!/bin/bash

# Define comparison operators
after=">"
before="<"
on="=="

# Get user input
read -p "Enter the GHE organization name: " ORG_NAME
read -p "Enter the timeframe of returned repos needed (before/after/on): " TIMEFRAME
read -p "Enter the date in specified format (YYYY-MM-DD): " DATE
read -p "Show active, archived, or both repository types? (active/archived/both): " show_archived

# Determine the archive flag for gh repo list
if [[ "$show_archived" == "archived" ]]; then
  archive_flag="--archived"
elif [[ "$show_archived" == "active" ]]; then
  archive_flag="--no-archived"
elif [[ "$show_archived" == "both" ]]; then
  archive_flag=""
else
  echo "Invalid input for repository type. Please use 'active', 'archived', or 'both'."
  exit 1
fi

# Get all repos for organization
gh repo list "$ORG_NAME" --limit 2000 $archive_flag --json name > all_org_repos.json

# Input JSON file
json_file="all_org_repos.json"

# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
  # Extract repository name
  REPONAME=$(echo "$obj" | jq -r '.name')

  # Determine the comparison operator based on user input
  if [[ "$TIMEFRAME" == "before" ]]; then
    operator=$before
  elif [[ "$TIMEFRAME" == "after" ]]; then
    operator=$after
  elif [[ "$TIMEFRAME" == "on" ]]; then
    operator=$on
  else
    echo "Invalid timeframe. Please use 'before', 'after', or 'on'."
    exit 1
  fi

  # Get the creation date and filter based on the timeframe
  gh api repos/"$ORG_NAME"/"$REPONAME" --jq '{ "repo": "'"$ORG_NAME/$REPONAME"'", "createdAt": .created_at }' | jq -r 'if .createdAt '"$operator"' "'"${DATE}T00:00:00Z"'" then "repo,createdAt\n\(.repo),\(.createdAt)" else empty end' >> repo_creation_date.csv
done