# Get all archived repos for the forest-service org and export to json
gh repo list forest-service --archived --json name --limit 2000 > archived_repos.json

# Archived repos json file
json_file="archived_repos.json"

# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
# Extract repository name
reponame=$(echo "$obj" | jq -r '.name')

# Execute transfer
gh api repos/FS-Archived-Repos/$reponame/transfer -f new_owner=Orphaned-or-Transitional-Repos 
done

