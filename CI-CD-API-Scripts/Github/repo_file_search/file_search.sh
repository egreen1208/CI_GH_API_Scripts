

#!/bin/bash

# Repository to search
REPO="forest-service/CI-Team-GitHub-API-Scripts"

# Output JSON file
OUTPUT_FILE="repo_info.json"

# 1. Check for README.md
if gh search code --repo "$REPO" --json path filename:README.md > results.json; then
  if jq -e '. | length > 0' results.json >/dev/null; then
    echo "$REPO - README.md is present"
    readme_status="present"
  else
    echo "$REPO - README.md is not present"
    readme_status="not present"
  fi
  rm results.json # Clean up
else
  echo "Error checking for README.md in $REPO"
  readme_status="error"
fi

# 2. Check if Wiki is enabled 
if wiki_enabled=$(gh repo view "$REPO" --json hasWikiEnabled | jq -r '.hasWikiEnabled'); then
  echo "$REPO - Wiki Enabled: $wiki_enabled"
else
  echo "Error checking wiki status for $REPO"
  wiki_enabled="error"
fi

# 3. List all .md files
echo "$REPO - Markdown files:"
if all_md_files=$(gh search code --repo "$REPO" --extension md --json path | jq -r '.[] | .path'); then
    echo "$all_md_files" | tr ' ' '\n'  # Print each file on a new line
else
  echo "No .md files found or error occurred while searching in $REPO"
  all_md_files="None found or error occurred"
fi

# Export results to JSON (Corrected)
jq -n --arg repo "$REPO" --arg readme "$readme_status" --arg wiki "$wiki_enabled" --arg md_files "$all_md_files" '{repository: $repo, "README.md": $readme, "Wiki Enabled": $wiki, "Markdown Files": $md_files}' > "$OUTPUT_FILE"