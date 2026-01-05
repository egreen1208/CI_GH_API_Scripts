#!/bin/bash
# Get all fs repos
gh repo list ORGNAME --limit 2000 --json name > allfsrepos.json


# Input JSON file
json_file="FILE_NAME.json"

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# CSV file
csv_file="FILE_NAME_$timestamp.csv"

# Print CSV header
echo "reponame,branch_count" > "$csv_file"

# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
  # Extract name
  reponame=$(echo "$obj" | jq -r '.name')

  # Get branch count for the repository
  branch_count=$(gh api repos/ORGNAME/"$reponame"/branches --paginate | jq length)

  # Print repo name and branch count to CSV
  echo "$reponame,$branch_count" >> "$csv_file"
done

