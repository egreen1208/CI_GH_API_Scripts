#!/bin/bash

# Replace these values with your Jenkins instance URL, username, and API token.
jenkins_url="https://jenkins.fs.usda.gov"
username="Your_Username"
api_token="Your_Token"

# Groovy script to get all users along with their creation date, last login, and email
groovy_script='
import org.acegisecurity.*
import hudson.model.User
import hudson.tasks.Mailer
import jenkins.security.*
import java.util.Date

println "User ID,Display Name,Email,Logged in before,Creation Date"

User.getAll().each { u ->
    def prop = u.getProperty(LastGrantedAuthoritiesProperty)
    def email = u.getProperty(Mailer.UserProperty)?.getAddress()
    def realUser = false
    def timestamp = null
    if (prop) {
        realUser = true
        timestamp = new Date(prop.timestamp).toString()
    }

    if (realUser) {
        println "${u.getId()},${u.getDisplayName()},${email},Yes,${timestamp}"
    } else {
        println "${u.getId()},${u.getDisplayName()},${email},No,"
    }
}
'

# URL-encode the Groovy script
encoded_groovy_script=$(printf '%s' "$groovy_script" | jq -s -R -r @uri)

# Make the API call to execute the Groovy script
response=$(curl -s -u "$username:$api_token" -X POST -d "script=$encoded_groovy_script" "$jenkins_url/scriptText")

# Generate a timestamp for the output file name
timestamp=$(date +"%Y%m%d_%H%M%S")

# Create the CSV file and add headers
csv_file="Jenkins_Users_$timestamp.csv"
echo "User ID,Display Name,Email,Logged in before,Creation Date" > $csv_file

# Append the response to the CSV file
echo "$response" >> $csv_file

echo "User information has been exported to $csv_file"