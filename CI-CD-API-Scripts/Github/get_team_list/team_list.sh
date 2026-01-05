#!/bin/bash

# GitHub Enterprise API settings
TOKEN="<your_token>"
GHE_HOST="code.fs.usda.gov"
ORG="forest-service"
TEAM_ID="NRM"

# Get top-level team information
TOP_LEVEL_TEAM=$(curl -s -H "Authorization: Bearer $TOKEN" "https://$GHE_HOST/api/v3/organizations/$ORG/team/$TEAM_ID")

# Get child teams of the top-level team
CHILD_TEAMS=$(curl -s -H "Authorization: Bearer $TOKEN" "https://$GHE_HOST/api/v3/organizations/$ORG/team/$TEAM_ID/teams")

# Prepare data for CSV export
echo "Team Name,Child Team" > teams_data.csv
echo "$TOP_LEVEL_TEAM" | jq -r --arg team_name "$ORG" '.name as $parent_team | $team_name as $parent_name | $parent_team.name as $parent_team_name | $parent_team_name, .[].name | "\($parent_name),\($parent_team_name),\(.)"' >> teams_data.csv

for child_team in $(echo "$CHILD_TEAMS" | jq -r '.[].slug'); do
    CHILD_TEAM_INFO=$(curl -s -H "Authorization: Bearer $TOKEN" "https://$GHE_HOST/api/v3/teams/$child_team")
    echo "$CHILD_TEAM_INFO" | jq -r --arg team_slug "$child_team" '.slug as $child_slug | .slug | "\($child_slug),\(.)"' >> teams_data.csv
done

echo "Data exported to teams_data.csv"