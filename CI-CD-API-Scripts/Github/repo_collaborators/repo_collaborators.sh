


#!/bin/bash

# Input JSON file containing repository names
json_file="nrm_repos_copy.json"

# # Loop through the JSON array  
jq -c '.[]' "$json_file" | while read -r obj; do


#   # Extract name
  reponame=$(echo "$obj" | jq -r '.name')

  # Loop through each repository
  gh api repos/forest-service/$reponame/collaborators?affiliation=direct | jq --arg REPO "$reponame" '[.[] | "\($REPO),\(.login)"] | @csv' >> nrm_repos_collaborators.csv

done 



