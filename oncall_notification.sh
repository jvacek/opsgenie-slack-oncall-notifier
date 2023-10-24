#!/bin/bash

# Query Opsgenie API to get the on-call schedule for a specific team
ops_response=$(curl -s -X GET  "https://${OPSGENIE_DOMAIN}/v2/schedules/${OPSGENIE_SCHEDULE_ID}/on-calls?flat=true" --header "Authorization: GenieKey ${OPSGENIE_API_KEY}") || {
    echo "Error: Failed to query the Opsgenie API"
    exit 1
}
schedule_name=$(echo "$ops_response" | jq -r '.data._parent.name')
emails=$(echo "$ops_response" | jq -r '.data.onCallRecipients[]')

# Translate emails into slack usernames
usernames=()
for email in $emails; do
    slack_user_response=$(curl -s -X POST -H "Authorization: Bearer $SLACK_USER_ACCESS_TOKEN" -H "Content-Type: application/json; charset=utf-8"  "https://slack.com/api/users.lookupByEmail?email=${email}") || {
        echo "Error: Failed to query the Slack API"
        exit 1
    }
    slack_user_id=$(echo "$slack_user_response" | jq -r '.user.id')
    usernames+=( "$slack_user_id" )
done
at_string=$(printf "%s", "<@${usernames[*]}>")

# Compose the message
message="Hello ${at_string} you are on call for the ${schedule_name} schedule. Make sure you've unmuted the channel for the duration. Please :ack: this message."
echo "$message"

# Post the message to Slack using curl
curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL" || {
    echo "Error: Failed to post the message to Slack"
    exit 1
}
