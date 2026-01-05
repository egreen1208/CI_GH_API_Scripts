

#!/bin/bash

# Input JSON files
usernames_file="usernames.json"
team_file="child_teams3.json"

# Loop through usernames
jq -c '.[]' "$usernames_file" | while read -r user_obj; do
    username=$(echo "$user_obj" | jq -r '.login')

    # Loop through teams for each username
    jq -c '.[]' "$team_file" | while read -r team_obj; do
        team_slug=$(echo "$team_obj" | jq -r '.slug')

        # Construct API URL and DELETE
        gh api -X DELETE "orgs/forest-service/teams/$team_slug/memberships/$username"

        echo "Removed $username from team $team_slug"  # Optional for feedback
    done
done

