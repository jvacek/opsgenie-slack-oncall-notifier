# Use a base image with the necessary tools (e.g., curl and jq)
FROM alpine:latest

RUN apk update \
 && apk add --no-cache curl jq \
 && rm -rf /var/cache/apk/*

# Set environment variables
ENV OPSGENIE_API_KEY=your_opsgenie_api_key
ENV OPSGENIE_DOMAIN=your_opsgenie_domain
ENV OPSGENIE_SCHEDULE_ID=your_schedule_id
ENV SLACK_WEBHOOK_URL=your_slack_webhook_url
ENV SLACK_USER_ACCESS_TOKEN=your_slack_access_token

# Copy your Bash script into the container
COPY oncall_notification.sh /opt/oncall_notification.sh

# Make the script executable
RUN chmod +x /opt/oncall_notification.sh

# Define the command to run when the container starts
CMD ["/opt/oncall_notification.sh"]
