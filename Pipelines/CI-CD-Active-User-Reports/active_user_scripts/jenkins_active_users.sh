#!/bin/bash

jenkins_url="https://jenkins.fs.usda.gov"
username="$JENKINS_USERNAME"
api_token="$JENKINS_TOKEN"

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

encoded_groovy_script=$(printf '%s' "$groovy_script" | jq -s -R -r @uri)

response=$(curl -s -u "$username:$api_token" -X POST -d "script=$encoded_groovy_script" "$jenkins_url/scriptText")

timestamp=$(date +"%Y-%m-%d_%H%M")

csv_file="Jenkins_Users_$timestamp.csv"
echo "User ID,Display Name,Email,Logged in before,Creation Date" > $csv_file
echo "$response" >> $csv_file
echo "User information has been exported to $csv_file"


