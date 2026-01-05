#!/bin/bash

# Set your GitHub Enterprise base URL
BASE_URL="https://DOMAIN_NAME/api/v3"

# Set repository owner and name
OWNER="OWNER_NAME"
json_file="JSON_NAME.json"

# Array of labels to delete
LABELS=("label%1" "label%2" "label%3" "label%4")

# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
    REPO=$(echo "$obj" | jq -r '.name')
    echo "Processing repository: $REPO"

    # Loop through labels and delete them
for label in "${LABELS[@]}"
do
    echo "Deleting label: $label"
    gh api --method DELETE "repos/$OWNER/$REPO/labels/$label"

done

# Add the "Security" label
gh api --method POST "repos/$OWNER/$REPO/labels" -f name="Security" 

done


