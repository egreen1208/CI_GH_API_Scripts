#!/bin/bash

# To start this script you will need to first provide a list repositories in a .json file.
# If you have a .csv file with the names, you can convert the file using the csvtojson.py script that is in the directory.

# Set your GitHub Enterprise base URL
BASE_URL="https://code.fs.usda.gov/api/v3"

# Set repository owner and name
OWNER="forest-service"
json_file="<your_input.json>"
label_name="new_label_name"


# Loop through the JSON array
jq -c '.[]' "$json_file" | while read -r obj; do
    REPO=$(echo "$obj" | jq -r '.name')
    echo "Processing repository: $REPO"

# Add the "Security" label
#  Be sure to add your label description for the label flag
gh api --method POST repos/$OWNER/$REPO/labels -f name="$label_name" -f description='<label_description>' -f color='<pick_a_color>'

done

