#!/bin/bash

# This script will get all repos within the specified organization and export only repos that have not had a commit within one year of the current date.
org_name="forest-service"
one_year_ago=$(date -d "1 year ago" --iso-8601=seconds)

# Function to check if a repository has recent commits
check_repo() {
  repo_name=$1
  latest_commit=$(gh api repos/$org_name/$repo_name/commits | jq -r '.[0].commit.author.date')
  if [[ "$latest_commit" == "null" ]]; then
    echo "Repository $repo_name has no commits."
  elif [[ "$latest_commit" < "$one_year_ago" ]]; then
    echo "$repo_name" >> No_Commits_Within_1Year.csv
  fi
}
echo "Repository Name" > No_Commits_Within_1Year.csv

# Get the list of repositories in the organization
repos=$(gh api orgs/$org_name/repos --paginate | jq -r '.[].name' | tr -d '\r')

# Iterate over the repositories and check for recent commits
for repo_name in $repos; do
  check_repo "$repo_name"
done


# gh api repos/forest-service/NRM-LocMinrls/commits | jq -r '.[0].commit.author.date'