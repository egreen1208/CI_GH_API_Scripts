#!/bin/bash
TOKEN="YOURS"
PORTFOLIO_KEY="Department___Application_Development"
GROUP_NAME="Application Development Assessment"
PERMISSION="codeviewer" #user, codeviewer, etc... 

project_keys=$(curl -s -X GET -G 'https://sca.fedgovcloud.us/api/components/tree' --data-urlencode "component=Department___Application_Development" --data-urlencode "&qualifiers=TRK" -H "Authorization: Bearer $TOKEN" | jq -r '.components[].key')

for project_key in $project_keys; do
    #remove portfolio key from start of project_key
    CLEAN_KEY=$(echo $project_key | sed 's/^Department___Application_Development//')
    echo $CLEAN_KEY
    curl -X POST 'https://sca.fedgovcloud.us/api/permissions/add_group' --data-urlencode "projectKey=$CLEAN_KEY" --data-urlencode "groupName=$GROUP_NAME" --data-urlencode "permission=$PERMISSION" -H "Authorization: Bearer $TOKEN"

   echo "Added $GROUP_NAME to project $project_key with $PERMISSION permission"
done
