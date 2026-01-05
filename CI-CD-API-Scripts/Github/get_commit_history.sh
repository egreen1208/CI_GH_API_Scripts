# gh api repos/forest-service/FAM-IM-AFF-Automated-Flight-Following/commits?since=2024-07-20T01:00:00

# git clone https://code.fs.usda.gov/forest-service/FAM-IM-AFF-Automated-Flight-Following
# gh api repos/forest-service/FAM-IM-AFF-Automated-Flight-Following/branches --paginate | jq -r '.[].name' | tr -d '\r' | while read -r branch; do
#     gh api "repos/forest-service/FAM-IM-AFF-Automated-Flight-Following/commits?sha=$branch&since=2024-07-20T00:00:00Z" | jq -r --arg branch "$branch" '.[] | select(.commit.committer.date >= "2024-07-20T00:00:00Z") | {sha: .sha, branch: $branch, committer_name: .commit.committer.name, commit_date: .commit.committer.date, message: .commit.message}'
# done > commit_history2.json
gh api repos/forest-service/FAM-IM-AFF-Automated-Flight-Following/branches --paginate | jq -r '.[].name' | tr -d '\r' | while read -r branch; do
    gh api "repos/forest-service/FAM-IM-AFF-Automated-Flight-Following/commits?sha=$branch&since=2024-07-26T00:00:00Z" --paginate | jq -r --arg branch "$branch" '.[] | select(.commit.committer.date >= "2024-07-20T00:00:00Z" and .commit.committer.name == "NEIL A. FLAGG") | {sha: .sha, branch: $branch, committer_name: .commit.committer.name, commit_date: .commit.committer.date, message: .commit.message}'
done > 7-26-2024_commit_history.json


