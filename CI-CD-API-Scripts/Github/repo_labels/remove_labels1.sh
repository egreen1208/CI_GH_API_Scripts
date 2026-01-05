#!/bin/bash

# Set your GitHub Enterprise base URL
BASE_URL="https://DOMAIN_NAME/api/v3"

# Set repository owner and name
OWNER="OWNER_NAME"
REPO="REPO_NAME"

# Read repository names from nrm_repos.json using jq
REPO_NAMES=$(jq -r '.users[].name' nrm_repos.json)

# Loop through repository names and perform actions
for repo_name in $REPO_NAMES
do
    echo "Processing repository: $repo_name"

    # Add your desired actions here (e.g., delete labels, add labels, etc.)
     gh api --method DELETE "repos/$OWNER/$repo_name/labels/SQ%20Bug"

done

# Add the "Security" label
gh api --method POST "repos/$OWNER/$REPO/labels" -f name="Security" -f color="#4b9fd5"
