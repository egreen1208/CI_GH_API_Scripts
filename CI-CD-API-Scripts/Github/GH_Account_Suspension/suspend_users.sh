# You will need to provide a list of gh usernames that will need to be suspended in a .csv file
# Make sure that csv is in same directory as .sh file
#!/bin/bash

csv_file="username.csv"
reason="Account suspended due to inactivity"
github_token="Your_Token"  # Store your token securely
gh_username="Your_Username"

# Download the CSV file 
curl --remote-name \
    --location \
    --user "$gh_username:$github_token" \
    https://code.fs.usda.gov/stafftools/reports/all_users.csv

dos2unix "$csv_file"

# Process each user in the CSV
while IFS=',' read -r username _; do
    echo "Suspending $username..."

    # Use the GitHub API to suspend the user
    gh api -X PUT "users/$username/suspended" \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $github_token" \
        -f reason="$reason" 
done < "$csv_file"

echo "User suspension complete!"
