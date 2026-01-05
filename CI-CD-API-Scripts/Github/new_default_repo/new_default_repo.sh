#!/bin/bash
read -p "Enter new repo name: " new_repo_name
read -p "Enter name of person that will be repo admin: " repo_admin
read -p "Enter a brief description of repo use: " repo_description

# Set the owner of the repository
repo_owner="forest-service"

#  Create new repo from default-new-repo
gh repo create $repo_owner/$new_repo_name --template $repo_owner/default-new-repo --include-all-branches --internal 

# Edit repo to delete feature branches after merging and add description based on value set
gh repo edit $repo_owner/$new_repo_name --delete-branch-on-merge --description "Repository Admin: $repo_admin - $repo_description"

# Apply default rulesets
gh api repos/$repo_owner/$new_repo_name/rulesets -f "name=default" -f "target=branch" -f "enforcement=active" -f "rules[][type]=deletion" -f "rules[][type]=pull_request" -f "rules[][type]=non_fast_forward" 

if [[ -z "$repo_owner" || -z "$new_repo_name" ]]; then
  echo "Error: Please provide a repository in the format 'owner/name'."
  exit 1
fi

# Get all rulesets for the repository
rulesets_json=$(gh api repos/$repo_owner/$new_repo_name/rulesets)

# Check for errors
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to retrieve rulesets."
  exit 1
fi

# Extract ruleset ID and name using jq 
ruleset_id=$(echo "$rulesets_json" | jq -r '.[0].id')
ruleset_name=$(echo "$rulesets_json" | jq -r '.[0].name')

# Check if any rulesets were found
if [[ -z "$ruleset_id" || -z "$ruleset_name" ]]; then
  echo "No rulesets found for repository '$repo_owner/$new_repo_name'."
  exit 0
fi

# Print the ruleset ID and name
echo "Ruleset ID: $ruleset_id"
echo "Ruleset Name: $ruleset_name"
# echo "Updated rules for ruleset '$repo_name'"


# Create temp.json with default settings to be applied to ruleset
# cat << EOF > default_ruleset.json
# JSON content for default ruleset
default_ruleset=$(cat <<EOF
{
  "name": "default",
  "target": "branch",
  "source_type": "Repository",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": [
        "refs/heads/[mds][aet][iva]*"
      ]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "pull_request",
      "parameters": {
        "require_code_owner_review": true,
        "require_last_push_approval": true,
        "dismiss_stale_reviews_on_push": true,
        "required_approving_review_count": 1,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "branch_name_pattern",
      "parameters": {
        "name": "",
        "negate": false,
        "pattern": "feature/*",
        "operator": "starts_with"
      }
    }
  ]
}
EOF
)
# # Lastly, this final line will apply the conditions in the temp.json to edit the ruleset with needed updates.
# gh api repos/$repo_owner/$new_repo_name/rulesets/$ruleset_id --method PUT --input default_ruleset.json

# echo "New repo '$new_repo_name' has been created with default $repo_owner settings"

# Apply the conditions in the default_ruleset to edit the ruleset with needed updates
echo "$default_ruleset" | gh api repos/$repo_owner/$new_repo_name/rulesets/$ruleset_id --method PUT --input -
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to update ruleset."
  exit 1
fi

echo "New repo '$new_repo_name' has been created with default $repo_owner settings"
