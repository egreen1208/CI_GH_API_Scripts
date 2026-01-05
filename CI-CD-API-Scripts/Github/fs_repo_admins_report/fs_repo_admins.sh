#!/bin/bash


# Get all fs repos
gh repo list forest-service --limit 2000 --json name > allfsrepos.json


# Input JSON file
json_file="allfsrepos.json"


# Create an empty CSV file
> fs_repo_admins.csv


# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
# Extract repository name
reponame=$(echo "$obj" | jq -r '.name')


# Retrieve collaborators 
gh api repos/forest-service/$reponame/collaborators?affiliation=direct | jq --arg REPO "$reponame" '( [.[] | select(.site_admin==false) | select(.permissions.admin == true)] | map("\($REPO),\(.login)") ) | @csv' >> fs_repo_admins.csv
done

python csv_to_excel.py

echo "Python script execution complete."

done

gh api teams/193/repos --paginate --jq '[.[] | {name: .name}]'


