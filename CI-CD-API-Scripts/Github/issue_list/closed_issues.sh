# Run just this line to create a json file of all the closed issue numbers to loop through
# gh issue list --repo forest-service/NRM-Drupal-Website --state closed --limit 500 --json number | jq '[.[] | {number: .number}]' > NRM-Drupal-Website_closed_issues.json

# Input JSON file
json_file="json_name.json"

# Create an empty CSV file
> csv_name.csv

# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
  # Extract issue number
  issue_number=$(echo "$obj" | jq -r '.number')

  # Query GitHub API for issue details and filter for closed_by = curtis-phelps
  gh api repos/forest-service/NRM-Drupal-Website/issues/$issue_number | \
    jq -r 'if .closed_by.login == "Angela-Castillo" then 
              [ "\(.number) \(.closed_by.login // "unknown") \(.closed_at | fromdateiso8601 | strftime("%Y-%m-%d")) \(.title)" ] | @csv
           else empty end' >> NRM-Drupal-Website_closed_issues.csv
done
