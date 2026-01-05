gh api repos/ORG_NAME/REPO_NAME/branches --paginate | jq -r '.[].name' | tr -d '\r' | while read -r branch; do
    gh api "repos/ORG_NAME/REPO_NAME/commits?sha=$branch&since=2024-07-26T00:00:00Z" --paginate | jq -r --arg branch "$branch" '.[] | select(.commit.committer.date >= "2024-07-20T00:00:00Z" and .commit.committer.name == "NEIL A. FLAGG") | {sha: .sha, branch: $branch, committer_name: .commit.committer.name, commit_date: .commit.committer.date, message: .commit.message}'
done > 7-26-2024_commit_history.json


