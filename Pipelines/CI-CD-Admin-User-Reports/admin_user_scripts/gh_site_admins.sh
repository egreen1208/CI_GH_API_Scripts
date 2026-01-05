#!/bin/bash

access_token="$GITHUB_TOKEN"
url="https://code.fs.usda.gov/stafftools/reports/all_users.csv"

max_retries=10
retry_count=0
retry_delay=10

timestamp=$(date +"%Y%m%d_%H%M%S")

download_report() {
    response=$(curl -s -w "\nHTTP_STATUS_CODE:%{http_code}\n" -H "Authorization: Bearer $access_token" "$url")
    http_status=$(echo "$response" | grep "HTTP_STATUS_CODE" | awk -F: '{print $2}' | tr -d '[:space:]')
    response_body=$(echo "$response" | sed -e 's/HTTP_STATUS_CODE\\:.*//g')
}

filter_users() {
    echo "$1" | awk -F, 'NR==1 || ($5 == "admin" && $6 == "false")'
}

while [ $retry_count -lt $max_retries ]; do
    download_report
    echo "HTTP Status Code: $http_status"

    if [ "$http_status" -eq 200 ]; then
        echo "Report downloaded successfully."
        output_file="gh_site_admin_users_$timestamp.csv"
        filtered_users=$(filter_users "$response_body")
        echo "$filtered_users" > "$output_file"
        echo "Filtered user information has been exported to $output_file"
        exit 0
    else
        echo "Failed to download the report. HTTP Status Code: $http_status"
        echo "Response: $response_body"
        echo "Retrying in $retry_delay seconds..."
        sleep $retry_delay
        retry_count=$((retry_count + 1))
    fi
done

echo "Failed to download the report after $max_retries attempts."
exit 1